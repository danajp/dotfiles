// Voice dictation for omo (OmO Native), modelled on opencode-voice.
//
// Ctrl+R starts recording via sox; Ctrl+R again stops, transcribes with
// whisper-cli and appends the text to the prompt. Nothing is sent until Enter.
// `/stt` does the same toggle; `/stt cancel` discards a recording in progress.
//
// sox and whisper-cli come from the omo wrapper's PATH (lib/omo.nix); the
// model is the same file home-manager places for opencode.

import { spawn, execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const SHORTCUT = "ctrl+r";
const MODEL = path.join(
  os.homedir(),
  ".local",
  "share",
  "whisper-cpp",
  "ggml-large-v3-turbo-q5_0.bin",
);
const WAV = path.join(os.tmpdir(), `omo-stt-${process.pid}.wav`);
const STATUS_KEY = "voice";

type Proc = ReturnType<typeof spawn>;

export default function (pi: any) {
  let rec: Proc | null = null;
  let busy = false;

  const pulseAvailable = () => {
    try {
      execFileSync("pactl", ["info"], { stdio: "ignore", timeout: 3000 });
      return true;
    } catch {
      return false;
    }
  };

  const start = (ctx: any) => {
    if (!fs.existsSync(MODEL)) {
      ctx.ui.notify(`Whisper model missing: ${MODEL}`, "error");
      return;
    }
    try {
      fs.unlinkSync(WAV);
    } catch {}
    const input = pulseAvailable() ? ["-t", "pulseaudio", "default"] : ["-d"];
    let stderr = "";
    rec = spawn("sox", [...input, "-r", "16000", "-c", "1", "-b", "16", WAV], {
      stdio: ["ignore", "ignore", "pipe"],
    });
    rec.stderr?.on("data", (d) => (stderr += d.toString()));
    rec.on("error", (err) => {
      rec = null;
      ctx.ui.setStatus(STATUS_KEY, undefined);
      ctx.ui.notify(`Recording failed: ${err.message}`, "error");
    });
    rec.on("exit", (code) => {
      // Only a crash shows up here; a deliberate stop clears `rec` first.
      if (rec && code !== 0 && code !== null) {
        rec = null;
        ctx.ui.setStatus(STATUS_KEY, undefined);
        ctx.ui.notify(`sox exited (${code}): ${stderr.trim().split("\n").pop() ?? ""}`, "error");
      }
    });
    ctx.ui.setStatus(STATUS_KEY, "● recording (ctrl+r to stop)");
  };

  const stopRecorder = (): Promise<void> =>
    new Promise((resolve) => {
      const p = rec;
      rec = null;
      if (!p) return resolve();
      p.once("exit", () => resolve());
      p.kill("SIGINT");
      setTimeout(() => p.kill("SIGKILL"), 2000).unref();
    });

  const transcribe = (): Promise<string> =>
    new Promise((resolve, reject) => {
      const p = spawn("whisper-cli", ["-m", MODEL, "-f", WAV, "-l", "auto", "-np", "-nt"], {
        stdio: ["ignore", "pipe", "pipe"],
      });
      let out = "";
      let err = "";
      p.stdout.on("data", (d) => (out += d.toString()));
      p.stderr.on("data", (d) => (err += d.toString()));
      const timer = setTimeout(() => {
        p.kill("SIGKILL");
        reject(new Error("whisper-cli timed out after 60s"));
      }, 60_000);
      p.on("error", (e) => {
        clearTimeout(timer);
        reject(e);
      });
      p.on("exit", (code) => {
        clearTimeout(timer);
        if (code !== 0) return reject(new Error(err.trim().split("\n").pop() || `whisper-cli exited ${code}`));
        resolve(
          out
            .replace(/\[.*?\]/g, "")
            .replace(/\(.*?\)/g, "")
            .replace(/\s+/g, " ")
            .trim(),
        );
      });
    });

  const stop = async (ctx: any) => {
    busy = true;
    ctx.ui.setStatus(STATUS_KEY, "• transcribing");
    try {
      await stopRecorder();
      const text = await transcribe();
      if (!text) {
        ctx.ui.notify("No speech detected", "warning");
        return;
      }
      const current = ctx.ui.getEditorText();
      ctx.ui.setEditorText(current ? `${current.replace(/\s*$/, "")} ${text}` : text);
    } catch (e: any) {
      ctx.ui.notify(`Transcription failed: ${e.message}`, "error");
    } finally {
      busy = false;
      ctx.ui.setStatus(STATUS_KEY, undefined);
      try {
        fs.unlinkSync(WAV);
      } catch {}
    }
  };

  const toggle = async (ctx: any) => {
    if (busy) {
      ctx.ui.notify("Still transcribing", "warning");
      return;
    }
    if (rec) await stop(ctx);
    else start(ctx);
  };

  const cancel = async (ctx: any) => {
    if (!rec) return;
    await stopRecorder();
    ctx.ui.setStatus(STATUS_KEY, undefined);
    ctx.ui.notify("Recording cancelled", "info");
  };

  pi.registerShortcut(SHORTCUT, {
    description: "Voice: start/stop recording and insert the transcript",
    handler: toggle,
  });

  pi.registerCommand("stt", {
    description: "Voice dictation: /stt toggles recording, /stt cancel discards it",
    handler: async (args: string, ctx: any) => {
      if (args.trim() === "cancel") return cancel(ctx);
      return toggle(ctx);
    },
  });

  pi.on("session_shutdown", async () => {
    await stopRecorder();
  });
}

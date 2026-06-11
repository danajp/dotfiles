// OpenCode plugin adapter for dcg (Destructive Command Guard).
//
// dcg speaks Claude Code's PreToolUse hook protocol over stdin/stdout.
// OpenCode plugins are in-process JavaScript, so this bridges the two by
// spawning dcg before bash tool calls and throwing when dcg returns a denial.

export const DcgGuard = async () => {
  const dcg = "@dcg@";

  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return;

      const command = output?.args?.command;
      if (typeof command !== "string" || command.trim() === "") {
        throw new Error("blocked by dcg: bash command was missing or invalid");
      }

      const payload = JSON.stringify({
        tool_name: "Bash",
        tool_input: { command },
      });

      const proc = Bun.spawn([dcg], {
        stdin: "pipe",
        stdout: "pipe",
        stderr: "pipe",
        env: { ...process.env, DCG_ROBOT: "1" },
      });

      proc.stdin.write(payload);
      proc.stdin.end();

      const [exitCode, out, err] = await Promise.all([
        proc.exited,
        new Response(proc.stdout).text(),
        new Response(proc.stderr).text(),
      ]);

      // Empty stdout means dcg allowed the command.
      const last = out.trimEnd().split("\n").pop();
      if (!last) {
        if (exitCode === 0) return;
        throw new Error(
          `blocked by dcg: guard exited with ${exitCode}${err ? `: ${err.trim()}` : ""}`,
        );
      }

      let result;
      try {
        result = JSON.parse(last);
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        throw new Error(`blocked by dcg: guard returned malformed JSON: ${message}`);
      }

      if (result?.hookSpecificOutput?.permissionDecision === "deny") {
        const reason =
          result.hookSpecificOutput.permissionDecisionReason ?? "blocked by dcg";
        throw new Error(reason);
      }

      if (exitCode !== 0) {
        throw new Error(
          `blocked by dcg: guard exited with ${exitCode}${err ? `: ${err.trim()}` : ""}`,
        );
      }
    },
  };
};

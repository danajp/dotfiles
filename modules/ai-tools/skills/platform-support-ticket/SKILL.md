---
name: platform-support-ticket
description: >
  Log a Developer Experience (DevEx / platform) dev-support rotation request as a Jira ticket
  from a Slack thread. Use this skill when given a Slack thread link (or asked to "make a support
  ticket", "log a support request", "create a DEX support card", or "triage this thread") and the
  request is dev-support / platform-support work. Reads the full thread, classifies it against the
  support taxonomy, drafts the ticket for approval, then creates it in project DEX under epic
  DEX-829 with the platform-support labels and a triage comment. The only Slack post it makes is a
  link to the created ticket, posted back in the thread after the issue exists.
---

# Platform Support Ticket

You are helping the user log a dev support rotation request as a Jira ticket, based on a Slack
thread they give you.

## Input

A link to a Slack thread (a `slack.com/archives/<CHANNEL_ID>/p<TS>` URL), or a channel + message
timestamp. If the user has not given you a thread link, ask for one before doing anything else.

## Fixed configuration

Do not guess these. They are verified constants for this workflow.

| Item | Value |
| --- | --- |
| Atlassian cloudId | `28363aa1-5a3e-4e70-9ca4-7b347c22f288` (`greenhouseio.atlassian.net`) |
| Project | `DEX` — "Developer Experience v2" (project id `13719`) |
| Issue type | `Support Request` (id `11945`) |
| Epic | `DEX-829` — "Operational - Support Channel - Q3" |
| Epic Link field | `customfield_10007` (classic Epic Link) |
| Base label | `platform-support` (always applied) |

The created issue must always carry the `platform-support` label PLUS exactly one category label
from the taxonomy.

## Steps

Follow these in order. Do not skip the approval gate.

1. **Read the full Slack thread, including all replies.** Use `slack_read_thread` with the
   channel ID and the parent message `ts` parsed from the link (see "Parsing the Slack link"
   below). Read every reply, not just the parent. **Do not post anything to Slack while reading or
   triaging.** The one and only allowed Slack post is the ticket-link reply in step 7, and only
   after the issue exists.

2. **Decide whether the request belongs to our team.** If it does not belong to DevEx / platform
   support, tell the user where it should go instead and stop. Do not create a ticket.

3. **Pick exactly one category** from the taxonomy below. If two categories fit, pick the one that
   matches the work we will actually do, and state why in your final reply.

4. **Draft the ticket. Show the draft to the user and wait for explicit approval before you create
   anything.** The draft must show: summary, issue type, epic link, the full label set, and the
   description. Do not call `createJiraIssue` until the user approves.

5. **On approval, create the issue** in project `DEX` with:
   - Issue type `Support Request`.
   - Epic link `DEX-829` — set via `additional_fields: { "customfield_10007": "DEX-829" }`. If the
     create call rejects that field, retry using `parent: "DEX-829"` instead.
   - Labels: `platform-support` plus the one category label.
   - Description containing: the Slack thread permalink, the requester (who asked), and the ask in
     their own words.

6. **After creating, add one comment** recording the triage: what the request is, what you have
   investigated so far, who to consult, and the next step. Use `addCommentToJiraIssue`.

7. **Post the ticket link back in the thread.** This is the only Slack post this skill makes. Use
   `slack_send_message` with `thread_ts` set to the parent message `ts` so the reply lands in the
   thread, not the channel. Keep it to a short, factual link post, for example:
   `Logged this as <https://greenhouseio.atlassian.net/browse/<KEY>|<KEY>>.` Post only the link and
   the key — no triage detail, no root-cause commentary. Do not react, DM, or post anywhere else.

8. **Reply to the user** with:
   - the issue key,
   - the issue URL (`https://greenhouseio.atlassian.net/browse/<KEY>`),
   - confirmation that you posted the link in the thread, and the exact text you posted.

   If you want to say more than a link in the thread (extra context, next steps), draft that longer
   message here and let the user post it themselves — only the link reply is posted automatically.

## Parsing the Slack link

A thread URL looks like:

```
https://greenhouse-io.slack.com/archives/C0BDVF099NH/p1788271567489389
```

- Channel ID = the segment after `/archives/` (e.g. `C0BDVF099NH`).
- The `p1788271567489389` part is the message timestamp with the dot removed. Reinsert the dot
  before the last 6 digits to get the `ts`: `1788271567.489389`.
- If the URL has a `?thread_ts=<ts>&cid=<channel>` query string, prefer those explicit values — the
  `thread_ts` is the parent message, and a `p...` value with a `thread_ts` present means the link
  points at a reply, so read the thread from `thread_ts`.

Identify the **requester** as the author of the parent message (the person asking for help), not
the on-call responder, unless the thread makes clear someone else owns the ask.

## Taxonomy

Pick exactly one. The label is what goes on the issue alongside `platform-support`.

| Category | Label | Covers |
| --- | --- | --- |
| Access and Permissions | `support-access` | IAM roles, Datadog, Cloudflare, Snowflake roles, GitHub teams, service accounts |
| Release and Deployment | `support-release` | Stuck or failing releases, rollbacks, pipelinectl, release pipeline behavior |
| Environment and Infrastructure | `support-infra` | Degraded pods, DB connections, disk space, Redis, TCP/DNS/Route53 |
| Tooling and CI Bugs | `support-ci-tooling` | CircleCI auth, Jira/GitHub sync, flaky tests, ArgoCD sync |
| Code Review Requests | `support-code-review` | PR review asks routed to platform |
| Data Platform and Snowflake | `support-data-platform` | New pipelines, schema or table changes, dataset access |
| Monitoring and Alerting | `support-monitoring` | Alert tuning, cardinality, thresholds, false positives |
| Security and Vulnerability | `support-security` | CVE remediation, security patches |
| How To and Guidance | `support-how-to` | Process questions needing direction, not a fix |

## Writing style

Write the ticket (summary, description, and comment) in **ASD-STE100 Simplified Technical English**:

- Short sentences. One instruction or one fact per sentence.
- Use the simplest verb. Use approved technical words. Avoid synonyms for the same thing — pick one
  term and keep it.
- Active voice. Present or simple future tense.
- **No preamble.** Do not open with filler ("This ticket is about…"). State the request directly.
- **No speculation about root cause.** Record what the thread says and what you observed. Do not
  guess why it happens unless the thread states it.

## Tool reference

- `slack_read_thread(channel_id, message_ts)` — read the full thread.
- `slack_send_message(channel_id, message, thread_ts=<parent ts>)` — used ONCE, in step 7, to post
  the ticket link as a threaded reply after the issue exists. Do not use any other Slack send/draft/
  react tool, and do not call this before the issue is created.
- `createJiraIssue(cloudId, projectKey="DEX", issueTypeName="Support Request", summary, description,
  additional_fields={ "labels": [...], "customfield_10007": "DEX-829" })`.
- `addCommentToJiraIssue(cloudId, issueIdOrKey, commentBody)` — the triage comment.
- `editJiraIssue` — only if you need to fix a field after creation (e.g. epic link fallback).

## Guardrails

- The ONLY Slack post allowed is the ticket-link reply in step 7, and only after the issue is
  created. Do not post anything to Slack while reading or triaging, and never post the triage
  detail or root-cause commentary to Slack — that stays in the Jira comment. If you want to say more
  than the link in the thread, hand that text to the user to post.
- Never create the issue before the user approves the draft.
- Exactly one category label, always plus `platform-support`.
- If the request is not DevEx/platform work, route it verbally and stop — do not create a ticket.
- Put the Slack permalink, requester, and verbatim ask in the description so the ticket is
  traceable without opening Slack.

---
description: Capture this session's takeaways in the best matching document
argument-hint: "[topic or filename]"
---

Capture the durable conclusions, suggestions, decisions, and takeaways from the
current conversation in a Markdown document under `~/Documents/`.

Optional topic or target hint from the user:

$ARGUMENTS

## Selection

1. Derive the main topic from the conversation and `$ARGUMENTS`. Ignore routine
   chat, tool output, implementation mechanics, and temporary dead ends unless
   they materially affect a conclusion.
2. Search recursively under `~/Documents/` for likely Markdown documents. Start
   with filenames and headings, then inspect the content of the strongest
   candidates. Do not choose a file based only on a shared keyword.
3. Reuse an existing document only when it clearly covers the same subject and
   purpose. Read the complete document before changing it.
4. If multiple documents are credible targets, ask the user to choose. If none
   is a strong match, create a clearly named `.md` document in the most suitable
   location under `~/Documents/`, following nearby naming conventions. Default
   to the root of `~/Documents/` when no subdirectory is clearly appropriate.

## Writing

- Preserve the target document's purpose, structure, heading hierarchy, tone,
  terminology, formatting, and level of detail.
- Integrate takeaways into the relevant existing sections rather than appending
  a generic transcript summary.
- Be concise and factual. Include only claims supported by the current context
  or already present in the target. Clearly label unresolved suggestions,
  assumptions, and open questions.
- Do not remove unrelated existing material. Do not silently replace an earlier
  conclusion when this session conflicts with it. Record the revision or
  disagreement explicitly.
- Avoid duplicate points. Consolidate overlapping material while preserving any
  meaningful nuance and prior provenance.
- Never include credentials, tokens, private keys, cookies, or unnecessary
  personal data.

## Session provenance

Maintain a `## Session history` section at the end of the document. Create it if
needed, while respecting an equivalent provenance section already used by the
file. Add one entry for this invocation using this shape:

```markdown
### YYYY-MM-DD · Short session topic

- Pi session: `<PI_SESSION_ID>`
- Contributions: Added or revised `<section names>` to capture <specific durable
  conclusions, suggestions, or decisions>.
- Status: Final conclusions, proposals, or open questions.
```

Obtain the date and `PI_SESSION_ID` from the environment. Do not include the full
session-file path. Make `Contributions` specific enough that a reader can tell
which parts came from this session. If this session supersedes or disputes older
content, say exactly what changed and retain enough history to understand why.
Do not add a history entry when there is no durable content to save.

After writing, reread the changed document and report:

- Whether it was created or updated
- Its path
- The sections changed
- Any ambiguity, conflict, or unsupported point intentionally left unresolved

---
description: Create a Linear ticket assigned to me in Todo
argument-hint: "<title and details>"
---

Create one Linear issue from the following request:

$ARGUMENTS

Use the Linear MCP tools. Set:

- Assignee to `me`
- Status to `Todo`

Derive a concise title and useful Markdown description from the request. Preserve
explicit team, project, labels, priority, due date, and other issue details. Do
not invent missing requirements.

A team is required to create a Linear issue. Use a team explicitly named in the
request. Otherwise, infer it only when the current conversation or Linear
workspace makes the choice unambiguous. If the team is ambiguous, or the request
is empty or lacks enough information for a useful title, ask one concise
clarifying question before creating the issue. Do not ask for confirmation when
the request is already sufficient.

Invocation of `/ticket` authorizes creating this one issue with these defaults.
After creation, report the issue identifier, title, status, assignee, and URL.

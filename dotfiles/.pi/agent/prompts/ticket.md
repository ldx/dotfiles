---
description: Create and label Linear issues assigned to me in Todo
argument-hint: "<title and details>"
---

Turn the following request into actionable Linear issues:

$ARGUMENTS

Use the Linear MCP tools. Choose the simplest structure that fits the work unless
 the user specifies one. Use one issue for a cohesive outcome, separate issues
 for independent outcomes, or a parent with subissues when separately trackable
 deliverables contribute to one shared outcome. In that case, create the parent
 first and link each subissue to it. Do not split routine steps into issues.

For every issue, set:

- Assignee to `me`
- Status to `Todo`

Give each issue a concise title and a Markdown description specific to its scope.
Preserve explicit team, project, labels, priority, due date, and other details
where applicable. Look up labels available to the selected team, including
workspace labels, and apply relevant ones to each issue based on its own scope.
If none fit, leave it unlabeled rather than guessing or creating a new label.
Do not invent missing requirements.

A team is required to create a Linear issue. Use a team explicitly named in the
request. Otherwise, infer it only when the current conversation or Linear
workspace makes the choice unambiguous. If the team is ambiguous, or the request
is empty or lacks enough information for a useful title, ask one concise
clarifying question before creating issues. Do not ask for confirmation when
the request is already sufficient.

Invocation of `/ticket` authorizes choosing the structure and creating, linking,
and labeling the resulting issues without a separate approval step. Report each
issue's identifier, title, status, assignee, labels, and URL. Group subissues
under their parent.

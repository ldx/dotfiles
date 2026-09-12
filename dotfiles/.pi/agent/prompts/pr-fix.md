---
description: Repair review feedback and CI failures on the active pull request
argument-hint: "[focus or instructions]"
---

Repair the active open pull request being worked on in the current session.

Optional focus or instructions from the user:

$ARGUMENTS

## Authorization

Invocation of `/pr-fix` explicitly authorizes:

- Addressing actionable pull-request review feedback
- Fixing CI failures caused by the pull request
- Editing the current working tree
- Running applicable local checks
- Creating Conventional Commits for the fixes
- Pushing the current branch normally
- Monitoring checks triggered by those pushes
- Replying to review threads with concise evidence and resolving threads that
  are clearly addressed

It does not authorize force-pushing, rebasing published commits, merging or
closing the pull request, changing its base branch, dismissing reviews, changing
secrets, bypassing checks, triggering a manual deployment, or modifying unrelated
issues or pull requests. Ask before doing any of those.

## Identify the pull request

1. Read the repository instructions and inspect the current conversation,
   repository, branch, upstream, working tree, and remotes.
2. Identify the pull request from an explicit PR reference in this session or
   from the current branch using the repository's normal GitHub tooling.
3. Continue only when exactly one open pull request clearly matches both the
   current work and repository. Do not select a PR merely because it was
   mentioned incidentally. If no matching open PR exists, stop without changing
   anything. If the match is ambiguous, ask the user to choose.
4. Record the PR number, URL, base branch, head branch, and current head commit.
   Confirm that the checked-out branch is the PR head before editing or pushing.

## Inspect before changing

1. Retrieve the complete current PR state, including:
   - Description and changed files
   - Reviews and review summaries
   - Inline review threads, including unresolved status and outdated context
   - Issue comments that contain actionable feedback
   - Required and optional checks for the current head commit
2. Read full failed-check logs rather than relying only on check names or
   summaries. Ignore failures from older head commits.
3. Classify each item as actionable, already addressed, informational, stale,
   disputed, waiting on reviewer input, or externally blocked. Do not treat
   automated suggestions as requirements without checking their correctness.
4. Inspect the relevant code, tests, and configuration before editing. Preserve
   unrelated user changes and do not overwrite concurrent work.

## Repair loop

1. Address all valid, actionable feedback and PR-caused check failures with the
   smallest coherent changes. If feedback conflicts with repository rules, the
   PR's stated goal, or other feedback, stop and ask rather than guessing.
2. Add or update tests for regression-prone behavior when appropriate. Do not
   weaken tests, checks, or production safeguards merely to make CI pass.
3. Run targeted local checks first, then the broader checks appropriate to the
   changed area.
4. Review the complete diff for scope, correctness, generated artifacts,
   credentials, secrets, debug code, and accidental personal information.
5. Create one or more focused Conventional Commits and push the PR head branch
   to its configured remote using a normal push.
6. Monitor checks for the pushed commit to completion. If a check fails because
   of these changes, inspect its logs, make the smallest correct fix, rerun local
   checks, commit, push, and monitor again.
7. Stop retrying when a failure is caused by infrastructure, permissions,
   credentials, quotas, flaky external services, or another external blocker.
   Report the evidence instead.
8. After the relevant pushed fix is visible on GitHub, reply concisely to each
   addressed review thread with what changed and the commit or verification
   evidence. Resolve only threads that are clearly satisfied. Leave open any
   disputed question, reviewer decision, or partially addressed request.
9. Re-fetch the PR state before finishing so the report reflects current review
   threads, head commit, and checks.

## Completion report

Report:

- PR number, title, and URL
- Commits pushed
- Feedback addressed, with threads replied to or resolved
- Feedback intentionally left open and why
- Local checks performed
- CI checks and final status for the current head commit
- Any external blocker or user decision still required

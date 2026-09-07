---
description: Commit, push, pass CI, and verify automatic deployment
argument-hint: "[commit intent]"
---

Ship the current completed change end-to-end.

Optional commit intent from the user:

$ARGUMENTS

## Authorization

Invocation of `/ship` explicitly authorizes:

- Committing the current task's intended changes
- Pushing the current branch normally
- Fixing failures caused by these changes
- Creating and pushing additional fix commits until CI passes
- Monitoring and verifying any deployment automatically triggered by the push

It does not authorize force-pushing, merging a pull request, tagging a release,
publishing a package, changing secrets, bypassing checks, or starting a manual
production deployment. Ask before doing any of those.

## Procedure

1. Read the repository instructions and inspect:
   - Current branch and upstream
   - Working-tree and staged changes
   - The complete diff
   - Relevant test, CI, and deployment configuration

2. Confirm that every changed file belongs to the current task.
   - Do not discard or include unrelated user changes.
   - Check the diff for credentials, secrets, generated files, debug code, and
     accidental personal information.
   - If the intended scope or destination branch is unclear, stop and ask.

3. Run the repository's applicable local checks before committing.
   - Prefer documented package scripts and project commands.
   - Include targeted tests for the changed area.
   - Run broader typecheck, lint, build, and test checks when applicable.
   - Do not weaken tests or CI configuration merely to make checks pass.

4. Review the resulting diff and create a Conventional Commit.
   - Derive a concise commit message from the actual change and `$ARGUMENTS`.
   - Do not amend or rewrite already-pushed commits unless explicitly asked.

5. Push the current branch to its configured upstream using a normal push.

6. Identify CI runs associated with the pushed commit and monitor them to
   completion.
   - Prefer `gh run watch` and `gh run view --log-failed` for GitHub Actions.
   - If CI fails because of the submitted change, diagnose it, implement the
     smallest correct fix, rerun relevant local checks, commit, and push again.
   - Continue until CI is green or an external blocker requires user action.
   - Do not repeatedly retry infrastructure, quota, permission, or credential
     failures without a reason to expect a different result.

7. Determine whether the successful push automatically triggers a deployment.
   - Infer this from repository documentation, workflow files, and deployment
     configuration rather than assuming.
   - If automatic deployment exists, monitor it using the provider CLI or API.
   - Verify the deployed commit/version and available health or smoke checks.
   - Do not trigger a manual deployment unless separately authorized.

8. Finish with a concise report:
   - Commit hash and message
   - Branch and remote pushed
   - Local checks performed
   - CI run and final status
   - Deployment target, deployed revision, and verification performed
   - Any remaining blocker or manual verification

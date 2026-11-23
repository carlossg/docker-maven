---
name: review-pr-build-failures
description: Review failed build checks on a GitHub pull request, determine whether a small number are transient, and rerun those failed build jobs once. Use when asked to inspect, check, or retry PR build failures.
---

# Review PR build failures

When asked to review a pull request's failed builds:

1. Read the PR's current checks and identify failed build jobs. Record the PR head revision. For the isolation count, use all build jobs for that head across the PR's image workflows and matrices, including passing and pending jobs, but exclude non-build checks and older attempts.
2. Read the logs for every failed build job. Find the first/root error in each log; do not classify downstream errors, such as a missing test image, without checking why that image was unavailable.
3. Decide whether failures are both transient and isolated:
   - For ten or more build jobs, treat failures as isolated when no more than five failed and they represent no more than 10% of the build jobs. For fewer than ten build jobs, use the single-failure limit instead of the 10% limit.
   - Transient evidence includes a runner or daemon that was unavailable, an external service or registry timeout, or a temporary network failure. Confirm that the error is not caused by a bad image reference, missing workflow step, invalid credentials, or another repeatable configuration problem.
   - Build, compile, assertion, and test failures are not transient just because only a few jobs failed. Similar failures across multiple configurations, or failures over either isolation limit, are not a limited transient set.
4. If the failures are both transient and isolated, recheck the PR head immediately before rerunning. If it changed, restart the review for the new head. Otherwise, rerun only the failed build jobs, once. Use the available CI rerun integration for the PR. If it cannot rerun because of permissions, report that plainly; do not imply that changing a local CLI account changes the integration's credentials.
5. Report the failed job count, the evidence for classifying the failures, and whether the rerun was accepted. Do not claim a rerun passed until its new results are available. If rerun jobs fail again, report the new failures instead of automatically retrying.

Do not rerun non-build checks or already-passing jobs as part of this procedure.

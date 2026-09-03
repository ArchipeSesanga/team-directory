## Question 1 — What is worth its own commit?

### Category A: High-value commit boundaries

**Bug fix**: should be isolated so it can be reverted independently later without dragging unrelated feature work back out with it, and so `git blame` on the fixed lines points to a commit that's actually about the bug, not about something else that happened to ride along.

**Feature**: deserves its own commit because it's a distinct reviewable unit; if it later needs to be reverted (e.g. it caused a regression), you want to be able to lift it out cleanly without also undoing bug fixes or refactors that happened to land nearby.

**Refactoring (rename, move, delete)**: needs to be separate from content changes because git's rename/move detection only works well when the commit is a pure rename with no edits mixed in. Bundling a rename with a content edit makes diff tools show it as an unrelated delete plus add, and you lose the file's history across the move.

Shared principle: if a commit fixes a bug and adds a feature and touches an unrelated bug in the same commit, it's not atomic. Reverting one forces you to fight the others.

### Category B: Changes NOT worth a separate commit

Whitespace and formatting: fixing indentation, trailing spaces, linter auto fixes.

Typo fixes: correcting spelling in comments, docs, or user facing strings, especially right after the commit that introduced the typo.

Concrete example from this project: a `console.log`/debug print added and removed within the same working session, before anything is pushed.

What you'd gain by splitting these out: almost nothing. None of these represent a state anyone would ever want to revert to independently (reverting "typo fix" just reintroduces the typo).

What you'd lose: a clean log. You end up with a confusing string of low information commits (`fix typo`, `remove log`, `fix typo again`), and `git blame` becomes less meaningful because it's now pointing at noise commits instead of the substantive change nearby.

### Category C: .gitignore scope

I'm ignoring `.env` (contains a dummy, obviously fake API key) and `*.log` (the tool's runtime output file).

**Why**: `.env` holds a secret. Even a fake one in this assignment, the habit matters because in a real project this is where API keys and credentials live. `*.log` is generated output from running the tool, not source code. It's regenerable and would just create diff noise every run.

**What a teammate would lose if `.env` were committed and later scrubbed from history**: scrubbing the remote (e.g. via `git filter-repo` or BFG) doesn't retroactively protect a secret that was ever pushed. Anyone who already cloned or fetched before the scrub still has the old commit sitting in their local `.git` history/reflog, and any fork made before the cleanup still carries the exposed value. The real fix in that scenario is always rotating the secret, not just rewriting history; the rewrite only stops new clones from seeing it. On top of that, every teammate with a stale clone now has to re-clone or force-reset to match the cleaned history, which is disruptive and error prone if anyone has local commits on top of the old state.

 * node_modules this one can be reproduced by downloading the package and it's huge
 * dist/build: this one are derived output not nsource code, sometimes can bring merge conflicts if working in a team because each computer will have his own artifacts
 * .DS_Store, Thumbs: this are natif filesystem from a macOs/windows 

---

## Question 2 — Choosing merge vs. rebase

### Merge

**What it preserves**: it preserves history, meaning we keep a record of the changes from main and the feature branch, then combine the two so you can see how main has incremented its codebase. It also saves work done in parallel: when two people are working simultaneously on separate branches and then join their work.

**What it discards**: nothing about the real sequence is discarded. That's the whole point of a merge.

### Rebase

**What it preserves**: a clean linear narrative. Reading main's history top to bottom looks like all the work happened in one continuous sequence, which is easier to scan.

**What it discards**: the true timing of divergence is erased, and original commit SHAs are rewritten.

**My choice for Part 3**: I'll use merge for the intentional conflict. The whole point of intentionally creating a conflict is to practice recognizing and resolving one at the moment two histories collide, and a merge commit is the only approach that actually records that collision as a real, inspectable event in the log rather than rewriting it away.

---

## Question 3 — Remote operations inventory

1. **`git push -u origin feature-branch`** (first push)
   Sends: all local commits on `feature-branch` GitHub doesn't have yet, and sets upstream tracking.
   Receives: confirmation. New branch ref created, or rejected.
   Expected on GitHub: new branch appears, containing exactly your local commits at that point.

2. **`git fetch origin`**
   Sends: a request. "What do you have that I don't?"
   Receives: any new commits/refs on `origin`, downloaded into local tracking refs (e.g. `origin/main`) but not merged into your working branch.
   Expected on GitHub: nothing changes. Fetch is read-only.

3. **`git pull origin main`**
   Sends: a fetch request, same as above.
   Receives: new commits on `main`, automatically merged (or rebased with `--rebase`) into your current branch locally.
   Expected on GitHub: nothing. Pull only reads from GitHub; the merge/rebase happens locally.

4. **`git push origin feature-branch`** (after rebasing onto latest main)
   Sends: your rewritten commits (new SHAs from the rebase).
   Receives: GitHub rejects this by default (non-fast-forward) since the history no longer matches what it has. You'd need `--force-with-lease`.
   Expected on GitHub: the remote branch ref moves to your new rebased chain; old commits become unreachable and any open PR updates its diff.

5. **Merge via GitHub's "Merge pull request" button** (or the local equivalent, `git push origin feature-branch:main`)
   Sends: triggers the merge/rebase on GitHub's servers.
   Expected on GitHub: `main` now includes the feature branch's commits, as a merge commit or fast-forward depending on the strategy chosen.

6. **`git push origin --delete feature-branch`** (cleanup, Task 5)
   Sends: a request to delete the branch ref.
   Receives: confirmation the ref was removed.
   Expected on GitHub: `feature-branch` no longer appears in the branch list.

7. **`git fetch --prune`**
   Sends: a request for current remote state.
   Receives: the current list of remote branches.
   Expected on GitHub: nothing. This only cleans up stale local remote-tracking refs to match what's actually still on GitHub.

### What pushing to GitHub cannot verify for you

A successful push only proves the commits were transferred and the ref was updated. It says nothing about whether the code is correct or complete. Specifically:

A stale rebase base: if I rebase without fetching first, I could rebase onto an outdated local copy of `main` that's behind GitHub's real `main`. The push still succeeds; git has no way to know my `main` was stale.

Broken code: `git push` is pure data transfer; it has no idea whether the code builds or tests pass. That's only checked if CI is wired up to run after the push (Part 5). The push itself is blind to correctness.

Wrong or missing changes: if I'm on the wrong branch, or forgot to `git add` something, the push succeeds and sends exactly what I did commit. It can't warn me about what I meant to include.

A force-push overwriting someone else's work: `--force` succeeds even if it silently discards commits a teammate pushed in the meantime; `--force-with-lease` protects against this, plain `--force` doesn't.

**Why**: `git push` operates at the level of object transfer and ref updates, a guarantee about data integrity, not about semantic correctness. Anything requiring actually running the code or knowing intent versus action is outside git's job. That's what CI and manual review are for.

---

## Question 4 — Commit message as specification

a. `fixed stuff`: implementation minutiae. Non-descriptive because we don't know what was actually fixed.
Rewrite: `Fix null pointer crash when user profile is empty`

b. `Update index.js`: implementation minutiae. It names the file that changed, not the behavior that changed.
Rewrite: `Add error handling for failed API requests` (or `Register new /health route`)

c. `WIP`: a checkpoint marker for unfinished work.
Rewrite: `WIP: Add draft implementation of user search filter (incomplete, tests pending)`

d. `Add email format validation so invalid addresses cannot be submitted`: behaviour. No rewrite needed.

e. `asdasd`: implementation minutiae, effectively meaningless. No real content to reconstruct from.

f. `Changed line 47 of notes.md`: implementation minutiae. Cites a line number, which is actively misleading since it becomes wrong the moment earlier lines shift. Describes where the change landed, not what changed or why.
Rewrite: `Correct meeting time in project notes`




Changes from Damian



## Assignment 1.2

1. Fork is suitable when you do not have acces or permission to a certain repo, by doing so it allows you to have your own version and then you can send a pull request so that the owner of the original repo can review and decide either they approve or disapprove the merge request.
 
so if one decides to to clone with no permission/access they won't be able to push to the original branch.

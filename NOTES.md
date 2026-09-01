PART 1 — Written Decisions

Question 1 — What is worth its own commit?

Category A: High-value commit boundaries
----------------------------------------
* A bug fix
* A feature
* Refactoring (rename, moving, deleting)
If a commit fixes a bug, it should not at the same time add a new feature or fix some other completely unrelated bug, otherwise it is not atomic.

Category B: Changes NOT worth a separate commit
-----------------------------------------------
* Whitespace and Formatting: Fixing indentation, removing trailing spaces, or running a code linter.
* Typo Fixes: Correcting spelling mistakes in code comments, documentation, or user-facing strings.

-What you would gain: Almost nothing because these changes do not affect the behaviour of the code base
-what you'd lose is a clean log, you end up with a confusing kist of commit and a less meaningful git blame

Category C: .gitignore scope
----------------------------

* node_modules/ //this one can be reproduced by downloading the package and it's huge
* dist/build //this one are derived output not nsource code, sometimes can bring merge conflicts if working in a team because each computer will have his own artifacts
* .DS_Store, Thumbs // this are natif filesystem from a macOs/windows


Question 2
---------

Merge
-----
What it preserves:
      - it poreserves history; meaning we keep record of the changes from the main and the feature branch then combine the two so you can see how the mnain has incremented it codebase 
      - Saves work in parallel, basically when two people are working simultaneously  on separate branches and then join their work.

What it discards: Nothing about the real sequence is discarded, that's the whole point of a merge

Rebase
------
What it preserves: A clean linear narative,reading main's history top to bottom looks like all the work happened in one continuous sequence, which is easier to scan.

What it discards: 
       - The true timing of divergence is erased.
       - Original commit SHAs are rewritten

My choice for Part 3 : 
--------------------
I'll use merge for the intentional conflict the whole point of intentionally creating a conflict is to practice recognizing and resolving one at the moment two histories collide, and a merge commit is the only approach that actually records that collision as a real, inspectable event in the log rather than rewriting it away.


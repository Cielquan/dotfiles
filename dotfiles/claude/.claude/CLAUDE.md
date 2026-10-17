# Personal instructions

## Editing files

- Never edit, create or write files unless the current prompt explicitly says so (e.g. "please edit this file"). Otherwise ask first.
- Permission covers only the single prompt it was given in, unless I explicitly grant a longer scope (e.g. "for this session until I revoke it"). Then it lasts for that scope and only for the files or actions I named.
- Running scripts that write or generate files counts as editing.
- Read-only commands are fine without asking.

## Attribution: Git - keep Claude's work separate from mine

Everything you do on GitHub runs under my account, so mark it clearly as yours.

### Commits

- End every commit message with this trailer: `Co-Authored-By: Claude {MODEL_NAME} <noreply@anthropic.com>`
- Never amend, squash or rebase commits you didn't make in this session.

### Branches

- Create your branches with the prefix `claude/`, e.g. `claude/fix-player-jump`.
- **Never** push directly to `main`. Open a PR instead.

### Issues and pull requests

- Add the label `claude` to every issue and PR you open.
- End every issue body, PR description and comment you write with:
  `🤖 Written by [Claude Code](https://claude.com/claude-code)`
- Don't edit the body or title of issues and PRs I wrote. Add a comment instead.
- Don't close, reopen, assign or relabel issues unless I ask you to.
- If you merge a PR, add a comment, that you did the merge.

# Maintainer Guidelines

**This guide is for maintainers.** These special people have **write
access** to Homebrew’s repository and help merge the contributions of
others. You may find what is written here interesting, but it’s
definitely not a beginner’s guide.

Maybe you were looking for the [Formula Cookbook](Formula-Cookbook.md) or [Cask Cookbook](Cask-Cookbook.md)?

## Overview

All Homebrew maintainers are encouraged to contribute to all parts of the project,
but there are four main teams that maintainers tend to be a part of:

- `brew` maintainers: this team maintains the [`Homebrew/brew`](https://github.com/Homebrew/brew) repository.
  See the [Homebrew/brew Maintainer Guide](Homebrew-brew-Maintainer-Guide.md) for more details about being a `brew` maintainer.
- Core maintainers: this team maintains the [`Homebrew/homebrew-core`](https://github.com/Homebrew/homebrew-core)
  repository. See the [Homebrew/homebrew-core Maintainer Guide](Homebrew-homebrew-core-Maintainer-Guide.md)
  for more details about being a core maintainer.
- Linux maintainers: this team maintains the [`Homebrew/linuxbrew-core`](https://github.com/Homebrew/linuxbrew-core)
  repository. See the [Homebrew/linuxbrew-core Maintainer Guide](Homebrew-linuxbrew-core-Maintainer-Guide.md)
  for more details about being a Linux maintainer.
- Cask maintainers: this team maintains the [`Homebrew/homebrew-cask`](https://github.com/Homebrew/homebrew-cask),
  [`Homebrew/homebrew-cask-drivers`](https://github.com/Homebrew/homebrew-cask-drivers),
  [`Homebrew/homebrew-cask-fonts`](https://github.com/Homebrew/homebrew-cask-fonts) and
  [`Homebrew/homebrew-cask-versions`](https://github.com/Homebrew/homebrew-cask-versions) repositories.
  See the [Homebrew/homebrew-cask Maintainer Guide](Homebrew-homebrew-cask-Maintainer-Guide.md)
  for more details about being a cask maintainer.

These documents are meant to serve as guiding principles. As a maintainer, you can make a call to either
request changes from a contributor or help them out based on their comfort and previous contributions.
Remember, as a team we [Prioritise Maintainers Over Users](Maintainers-Avoiding-Burnout.md) to avoid
burnout. If you wish to change or discuss any of the guidelines: open a PR to suggest a change.

## Mission

Homebrew aims to be the missing package manager for macOS (and Linux). Its primary goal is to be useful to as many people as possible, while remaining maintainable to a professional, high standard by a small group of volunteers. Where possible and sensible, it should seek to use features of macOS to blend in with the macOS and Apple ecosystems. On Linux and Windows, it should seek to be as self-contained as possible.

## Common “gotchas”

1. [Ensure you have set your username and email address properly](https://help.github.com/articles/setting-your-email-in-git/)
2. Sign off cherry-picks if you amended them (use `git -s`)
3. If the commit fixes a bug, use “Fixes \#104” syntax to close the bug report and link to the commit

### Add comments

It may be enough to refer to an issue ticket, but make sure changes are clear so that
if you came to them unaware of the surrounding issues they would make sense
to you. Many times on other projects I’ve seen code removed because the
new guy didn’t know why it was there. Regressions suck.

### Don’t allow bloated diffs

Amend a cherry-pick to remove commits that are only changes in
whitespace. They are not acceptable because our history is important and
`git blame` should be useful.

Whitespace corrections (to Ruby standard etc.) are allowed (in fact this
is a good opportunity to do it) provided the line itself has some kind
of modification that is not whitespace in it. But be careful about
making changes to inline patches—make sure they still apply.

### Closing issues/PRs

Maintainers (including the lead maintainer) should not close issues or pull requests (note a merge is not considered a close in this case) opened by other maintainers unless they are stale (i.e. have seen no updates for 28 days) in which case they can be closed by any maintainer. Any maintainer is encouraged to reopen a closed issue when they wish to do additional work on the issue.

Any maintainer can merge any PR they have carefully reviewed and is passing CI that has been opened by any other maintainer. If you do not wish to have other maintainers merge your PRs: please use the `do not merge` label to indicate that until you're ready to merge it yourself.

## Reverting PRs

Any maintainer can revert a PR created by another maintainer after a user submitted issue or CI failure that results. The maintainer who created the original PR should be given no less than an hour to fix the issue themselves or decide to revert the PR themselves if they would rather.

### Give time for other maintainers to review

PRs that are an "enhancement" to existing functionality i.e. not a fix to an open user issue/discussion, not a version bump, not a security fix, not a fix for CI failure, a usability improvement, a new feature, refactoring etc. should wait 24h Monday - Friday before being merged. For example,

- a new feature PR submitted at 5pm on Thursday should wait until 5pm on Friday before it is merged
- a usability fix PR submitted at 5pm on Friday should wait until 5pm on Monday before it is merged
- a user-reported issue fix PR can be merged immediately after CI is green

If a maintainer is on holiday/vacation/sick during this time and leaves comments after they are back: please treat post-merge PR comments and feedback as you would left within the time period and follow-up with another PR to address their requests (if agreed).

The vast majority of `Homebrew/homebrew-core` PRs are bug fixes or version bumps which can be self-merged once CI has completed.

## Communication

Maintainers have a variety of ways to communicate with each other:

- Homebrew's public repositories on GitHub
- Homebrew's group communications between more than two maintainers on private channels (e.g. GitHub/Slack)
- Homebrew's direct 1:1 messages between two maintainers on private channels (e.g. iMessage/Slack/carrier pigeon)

All communication should ideally occur in public on GitHub. Where this is not possible or appropriate (e.g. a security disclosure, interpersonal issue between two maintainers, urgent breakage that needs to be resolved) this can move to maintainers' private group communication and, if necessary, 1:1 communication. Technical decisions should not happen in 1:1 communications but if they do (or did in the past) they must end up back as something linkable on GitHub. For example, if a technical decision was made a year ago on Slack and another maintainer/contributor/user asks about it on GitHub, that's a good chance to explain it to them and have something that can be linked to in the future.

This makes it easier for other maintainers, contributors and users to follow along with what we're doing (and, more importantly, why we're doing it) and means that decisions have a linkable URL.

All maintainers (and lead maintainer) communication through any medium is bound by [Homebrew's Code of Conduct](https://github.com/Homebrew/.github/blob/HEAD/CODE_OF_CONDUCT.md#code-of-conduct). Abusive behaviour towards other maintainers, contributors or users will not be tolerated; the maintainer will be given a warning and if their behaviour continues they will be removed as a maintainer.

Maintainers should feel free to pleasantly disagree with the work and decisions of other maintainers. Healthy, friendly, technical disagreement between maintainers is actively encouraged and should occur in public on the issue tracker to make the project better. Interpersonal issues should be handled privately in Slack, ideally with moderation. If work or decisions are insufficiently documented or explained any maintainer or contributor should feel free to ask for clarification. No maintainer may ever justify a decision with e.g. "because I say so" or "it was I who did X" alone. Off-topic discussions on the issue tracker, [bike-shedding](https://en.wikipedia.org/wiki/Law_of_triviality) and personal attacks are forbidden.

# GitHub Actions

This project uses [GitHub Actions](https://docs.github.com/en/actions) workflows for pull request automation. These are separate from the [Azure Pipelines](AzurePipelines.md) which handle the build, test, and release CI/CD process.

All workflow files are located under [`.github/workflows/`](../.github/workflows/).

## Workflows

### Conventional Commits ([conventional-commits.yml](../.github/workflows/conventional-commits.yml))

This workflow validates that all commit messages in a pull request follow the [Conventional Commits](https://www.conventionalcommits.org/) specification. It runs [Commitsar](https://commitsar.aevea.ee/) via Docker on every pull request.

This ensures consistent commit history and enables automated versioning based on commit types.

### PR Review Bot ([pr-review.yml](../.github/workflows/pr-review.yml))

This workflow provides **AI-powered code review** on pull requests using the [`nventive/pull-request-bot`](https://github.com/nventive/pull-request-bot) action.

#### Triggers

The bot runs automatically when a pull request is:
- **Opened**
- **Synchronized** (new commits pushed)
- **Reopened**

#### Permissions

The workflow requires the following permissions:
- `contents: read` — to read the repository code.
- `pull-requests: write` — to post review comments and update the PR description.

#### Configuration

The bot behavior is configured in [`pull-request-bot.json`](../pull-request-bot.json):

| Setting | Value | Description |
|-|-|-|
| Model | Claude Opus | The AI model used for code review. |
| Excluded patterns | `tests/**`, `**/*.test.js` | Files excluded from review. |
| Max file size | 320 KB | Files larger than this are skipped. |
| Auto-fix enabled | Yes | The bot can suggest automatic fixes. |
| Confidence threshold | 85% | Minimum confidence required for auto-fix suggestions. |
| Max fixes per file | 5 | Maximum number of auto-fix suggestions per file. |
| PR description mode | Append | The bot appends a summary to the PR description. |

#### Required Secret

| Secret | Description |
|-|-|
| `ANTHROPIC_API_KEY` | API key for the Anthropic Claude model used by the PR Review Bot. This must be configured in the repository's [GitHub Actions secrets](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions). |

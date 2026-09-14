# RnD Agents PR Merge Notification Setup

This document explains how to set up automatic Slack notifications when PRs created by rnd-agents are merged to the main branch.

## Overview

When a PR created by rnd-agents (or any user with "rnd-agents", "cursor", or "agent" in their username) is merged to the main branch, a notification is automatically posted to the `#release-pending-prs` Slack channel (ID: `C06MF986B54`).

The notification includes:
- PR type: `[SEC]`, `[FR]`, or `[BUG]`
- Ticket ID: `[RD-XXXXX]`
- Version information
- Brief description
- Whether it was raised by a customer
- Owner with Slack mention

## Setup Instructions

### 1. Configure Slack Bot Token

You need to create a Slack app with the following permissions:
- `chat:write` - To post messages to channels

Then add the `SLACK_BOT_TOKEN` secret to your GitHub repository:

1. Go to your repository settings
2. Navigate to Secrets and variables → Actions
3. Create a new repository secret named `SLACK_BOT_TOKEN`
4. Paste your Slack Bot OAuth Token (starts with `xoxb-`)

### 2. Configure GitHub to Slack User Mapping (Optional)

To properly mention owners in Slack, you need to map GitHub usernames to Slack user IDs.

Create a JSON mapping and add it as a secret named `GITHUB_USER_TO_SLACK_MAPPING`:

```json
{
  "yuval-shimon": "U07P93D0V47",
  "yoav-stoler": "U0BDWSE96C9",
  "yuval-mishali": "U09PBU8NXGE"
}
```

To find Slack user IDs:
1. Open Slack
2. Click on a user's profile
3. Click "More" → "Copy member ID"

### 3. Add the Slack Bot to the Channel

Make sure your Slack bot is a member of the `#release-pending-prs` channel:

1. Go to the channel
2. Type `/invite @YourBotName`

## PR Metadata Extraction

The workflow extracts metadata from PRs as follows:

### PR Type
Extracted from:
1. Labels: `security`, `sec`, `feature`, `enhancement`, `bug`, `fix`
2. Title prefixes: `[SEC]`, `[FR]`, `[BUG]`, etc.

### Ticket ID
Extracted from PR title using pattern: `RD-[0-9]+`

Example: `[BUG][RD-12345] Fix authentication issue` → `RD-12345`

### Version
Extracted from:
1. PR body (description)
2. PR labels

Pattern: `v[0-9]+\.[0-9]+\.[0-9]+`

### Brief Description
The PR title with type and ticket ID prefixes removed.

### Customer Raised
Set to "Yes" if:
1. PR has a label containing "customer"
2. PR body mentions "customer raised", "raised by customer", or "customer reported"

### Owner
Extracted from:
1. PR assignee (if set)
2. PR author (fallback)

## Example Output

```
[SEC][RD-21907] Added new content to main for versions `v1.34.6`
• Brief: SSO tenants no longer receive built-in-auth plaintext passwords
• Raised by customer: No
• Owner: (Yuval Shimon)<@U07P93D0V47>
```

## Testing

To test the workflow without merging to main:

1. Create a test branch
2. Modify the workflow to trigger on that branch
3. Create and merge a test PR
4. Check the Slack channel for the notification

## Troubleshooting

### Message not posted

1. Check GitHub Actions logs for the workflow run
2. Verify the `SLACK_BOT_TOKEN` secret is set correctly
3. Ensure the bot has access to the channel
4. Check the bot has `chat:write` permission

### Wrong owner mentioned

1. Update the `GITHUB_USER_TO_SLACK_MAPPING` secret
2. Ensure the GitHub username matches exactly
3. Verify the Slack user ID is correct

### Missing metadata

1. Check PR labels and title format
2. Ensure the PR body includes version information
3. Review the workflow logs for extraction details

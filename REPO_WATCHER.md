# Repository Watcher

The Repository Watcher is a feature of MastodonBotEx that allows users to interact with the bot to:

- **Watch GitHub repositories** for new releases.
- **Receive direct messages** when new releases are published.
- **Add or remove tags** associated with repositories for public notifications.
- **Manage watched repositories** through various commands.

This feature enhances user engagement by providing timely updates on repositories of interest and leveraging Mastodon's tagging system to reach a broader audience.

## Table of Contents

- [Features](#features)
- [Commands](#commands)
  - [Add a Repository to Watch List](#1-add-a-repository-to-watch-list)
  - [Remove a Repository from Watch List](#2-remove-a-repository-from-watch-list)
  - [Add Tags to a Repository](#3-add-tags-to-a-repository)
  - [Remove Tags from a Repository](#4-remove-tags-from-a-repository)
  - [Get Repository Information](#5-get-repository-information)
  - [Help Command](#6-help-command)
- [How It Works](#how-it-works)
- [Data Models](#data-models)
  - [RepoCheck Schema](#1-repocheck-schema)
  - [UserRepoCheck Schema](#2-userrepocheck-schema)
- [Setup and Configuration](#setup-and-configuration)
- [Examples](#examples)
- [Technical Notes](#technical-notes)
- [Future Enhancements](#future-enhancements)

## Features

- **Watch GitHub Repositories**: Users can instruct the bot to watch specific GitHub repositories.
- **Direct Notifications**: Users receive direct messages when new releases are available.
- **Public Announcements**: The bot posts public status updates with associated tags when a repository has a new release.
- **Tag Management**: Users can add or remove tags associated with repositories.
- **Information Retrieval**: Users can request information about watched repositories.

## Commands

### 1. Add a Repository to Watch List

**Command**: `/github <owner>/<repo> #tag1 #tag2 ...`

**Description**: Adds a GitHub repository to the watch list with optional tags.

**Example**:

```
/github octocat/Hello-World #opensource #updates
```

**Bot Response**:

- Sends a direct message to the user: "You have started watching repository octocat/Hello-World."

### 2. Remove a Repository from Watch List

**Command**: `/github_remove <owner>/<repo>`

**Description**: Removes a GitHub repository from the watch list.

**Example**:

```
/github_remove octocat/Hello-World
```

**Bot Response**:

- Sends a direct message to the user: "You have stopped watching repository octocat/Hello-World."

### 3. Add Tags to a Repository

**Command**: `/tags_add <owner>/<repo> #tag1 #tag2 ...`

**Description**: Adds tags to a repository. Tags are used in public posts to make them discoverable.

**Example**:

```
/tags_add octocat/Hello-World #newrelease #github
```

**Bot Response**:

- Posts a public status: "Tags #newrelease #github have been added to octocat/Hello-World."

### 4. Remove Tags from a Repository

**Command**: `/tags_remove <owner>/<repo> #tag1 #tag2 ...`

**Description**: Removes tags from a repository.

**Example**:

```
/tags_remove octocat/Hello-World #github
```

**Bot Response**:

- Posts a public status: "Tags #github have been removed from octocat/Hello-World."

### 5. Get Repository Information

**Command**: `/info <owner>/<repo>`

**Description**: Retrieves information about a watched repository.

**Example**:

```
/info octocat/Hello-World
```

**Bot Response**:

- Posts a public status with repository information, including last checked time, last release tag, and associated tags.

### 6. Help Command

**Command**: `/help`

**Description**: Displays help information with available commands.

**Bot Response**:

- Posts a public status with the list of available commands and their descriptions.

## How It Works

### 1. User Interaction

Users send commands to the bot via direct messages or mentions. The bot processes these commands and performs actions accordingly.

### 2. Repository Tracking

When a user adds a repository to watch:

- The bot checks if the repository exists in its database (`RepoCheck`).
- If not, it creates a new entry with the repository information.
- The bot associates the user with the repository in the `UserRepoCheck` schema.

### 3. Notifications

- **Direct Messages**: When a new release is detected, the bot sends a direct message to all users watching the repository.
- **Public Status Updates**: The bot posts a public status with release information and associated tags.

### 4. Tag Management

- Tags are managed globally per repository.
- Users can add or remove tags using `/tags_add` and `/tags_remove` commands.
- The bot enforces a maximum of 5 tags per repository.
- Tags are included in public status updates to enhance visibility.

## Data Models

### 1. RepoCheck Schema

Represents repositories being watched by the bot.

```elixir
schema "repo_checks" do
  field :repo, :string
  field :last_checked, :naive_datetime
  field :last_release_tag, :string
  field :tags, {:array, :string}

  timestamps()
end
```

- **repo**: The full name of the repository (e.g., `octocat/Hello-World`).
- **last_checked**: The timestamp when the repository was last checked for updates.
- **last_release_tag**: The tag of the last release detected.
- **tags**: A list of tags associated with the repository.

### 2. UserRepoCheck Schema

Associates users with repositories they are watching.

```elixir
schema "user_repo_checks" do
  field :user_acct, :string
  field :repo, :string
  field :complains, {:array, :string}
  field :suggestions, {:array, :string}

  timestamps()
end
```

- **user_acct**: The Mastodon account identifier of the user (e.g., `@username`).
- **repo**: The repository the user is watching.
- **complains**: Reserved for future use to track user complaints.
- **suggestions**: Reserved for future use to track user suggestions.

## Setup and Configuration

### 1. Database Migrations

Ensure all migrations are run to set up the database schemas for `RepoCheck` and `UserRepoCheck`. You can generate and run migrations using the following commands:

```sh
mix ecto.gen.migration create_repo_checks
mix ecto.gen.migration create_user_repo_checks
mix ecto.migrate
```

### 2. Environment Variables

Ensure you have your GitHub API token configured in your environment variables:

```dotenv
GITHUB_ACCESS_TOKEN=your_github_token
```

## Examples

### Adding a Repository with Tags

**User Message**:

```
/github octocat/Hello-World #opensource #github
```

**Bot Actions**:

- Adds `octocat/Hello-World` to `RepoCheck` if not already present.
- Adds `#opensource` and `#github` tags to the repository.
- Associates the user with the repository in `UserRepoCheck`.
- Sends a direct message: "You have started watching repository octocat/Hello-World."

### Receiving a Notification

When a new release is published for `octocat/Hello-World`:

- The bot updates `last_release_tag` in `RepoCheck`.
- Sends direct messages to all users watching the repository.
- Posts a public status:

  ```
  📦 New release for octocat/Hello-World!

  Version: v1.2.3
  Name: New Features

  [Release notes snippet]...

  Check it out and contribute! 🚀
  https://github.com/octocat/Hello-World

  #opensource #github
  ```

## Technical Notes

- **Concurrency**: The bot uses `GenServer` and `GenStage` for concurrent processing.
- **HTTP Clients**: Uses Tesla for HTTP requests to Mastodon and GitHub APIs.
- **Parsing**: Uses `NimbleParsec` for command parsing and `Floki` for HTML parsing.
- **Error Logging**: Errors and exceptions are logged for debugging purposes.

## Future Enhancements

- **Complaints and Suggestions**: The `complains` and `suggestions` fields in `UserRepoCheck` are reserved for future features, allowing users to provide feedback.
- **Additional Commands**: Potential to add more commands for enhanced interaction.
- **Customization**: Allow users to customize notification preferences.

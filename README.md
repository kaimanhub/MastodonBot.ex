# MastodonBotEx

Українська документація тут [README_UA](README_UA.md).

**MastodonBotEx** is an Elixir-based bot for interacting with the Mastodon API. This project provides a streaming client and a set of utilities to process notifications, parse data, and post statuses on Mastodon instances.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Streaming Client](#streaming-client)
  - [Notification Handler](#notification-handler)
  - [Repository Watcher](#repository-watcher)
- [Contributing](#contributing)
- [License](#license)

## Introduction

MastodonBotEx is designed to simplify the process of interacting with the Mastodon API. It provides tools to easily stream notifications, parse content, and automate actions like dismissing notifications or posting status updates. Whether you’re building a simple bot or a complex application, MastodonBotEx aims to be a helpful foundation.

## Features

- **Streaming Client:** Real-time streaming of user notifications using Tesla and Finch.
- **Notification Parsing:** Extract details from notifications, including sender information and message content.
- **Automated Actions:** Dismiss notifications and post responses based on received data.
- **Configurable:** Easily configure the bot using environment variables.

## Installation

To include MastodonBotEx in your project, add it to your `mix.exs` dependencies:

```elixir
defp deps do
  [
    {:mastodon_bot_ex, "~> 1.1.0"}
  ]
end
```

Then, run:

```sh
mix deps.get
```

As option to start process, run:

```sh
iex -S mix 
```

## Configuration

Before using MastodonBotEx, you need to configure it with your Mastodon instance’s domain and access token. This is typically done using environment variables.

### Environment Variables

Create a `.env` file in your project’s root directory and add the following:

```dotenv
MASTODON_DOMAIN=your.mastodon.instance
MASTODON_ACCESS_TOKEN=your_access_token
```

### Elixir Configuration

Ensure that these environment variables are loaded and used in your configuration. This can be done in your `config.exs`:

```elixir
import Config
Dotenv.load!()

config :mastodon_bot_ex,
  domain: System.fetch_env!("MASTODON_DOMAIN"),
  token: System.fetch_env!("MASTODON_ACCESS_TOKEN")
```

## Usage

### Streaming Client

The `MastodonBotEx.StreamingClient` module provides a function to stream user notifications. This function uses Tesla and Finch to connect to the Mastodon streaming API.

Example:

```elixir
MastodonBotEx.StreamingClient.stream_user_notifications()
```

This function starts streaming notifications and handles them according to your configuration.

### Notification Handler

The `MastodonBotEx.StreamingHandler` module processes the lines received from the stream. It distinguishes between data lines, heartbeat signals, and unknown data, and processes them accordingly.

Example:

```elixir
line = "data: {\"id\":\"123\", \"account\": {\"id\": \"456\", \"acct\": \"user\"}, \"status\": {\"id\": \"789\", \"content\": \"Hello!\"}}"
MastodonBotEx.StreamingHandler.process_line(line, "your_account_id")
```

### Notification Parser

The `MastodonBotEx.NotificationParser` module extracts relevant details from the notification data, such as the sender’s ID, name, channel ID, and the content of the message.

Example:

```elixir
data = %{"account" => %{"id" => "456", "acct" => "user"}, "status" => %{"id" => "789", "content" => "Hello!"}, "id" => "123"}
details = MastodonBotEx.NotificationParser.extract_message_details(data)
IO.inspect(details)
```

### Repository Watcher

For detailed usage of the Repository Watcher functionality, please refer to the [Repository Watcher Documentation](REPO_WATCHER.md).

## Contributing

We welcome contributions to MastodonBotEx! If you have an idea for a feature or find a bug, please open an issue. You can also fork the repository, make your changes, and submit a pull request.

### How to Contribute

We welcome contributions to MastodonBotEx! To maintain a clear and organized development process, we ask that every pull request (PR) is linked to an existing issue or enhancement request.

1. **Check Existing Issues:** Before starting any work, please check the [Issues](https://github.com/kaimanhub/MastodonBot.ex/issues) section to see if your enhancement or bug fix is already being discussed.
2. **Create an Issue:** If your contribution idea isn't covered, create a new issue or enhancement request.
3. **Fork the Repository:** Once the issue is created, fork the repository.
4. **Create a New Branch:** Create a branch with a descriptive name (`git checkout -b issue-123-feature-branch`), where `issue-123` references the issue number.
5. **Make Your Changes:** Commit your changes with clear and concise commit messages (`git commit -am 'Issue #123: Add new feature'`).
6. **Push the Branch:** Push the branch to your fork (`git push origin issue-123-feature-branch`).
7. **Submit a Pull Request:** Open a pull request, linking it to the issue it addresses.

Please ensure your code adheres to the existing style and that all tests pass before submitting a PR.

## License

This project is licensed under the Apache License v2.0. See the [LICENSE](LICENSE) file for more details.

# Andrii Yerzhykevych Kbot

## Description

A simple telegram bot.

Bot url - t.me/andriiyerzh_kbot

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/a-yerzhyk/kbot.git
   cd kbot
   ```

2. **Install dependencies:**
   ```bash
   go mod download
   ```

3. **Build the application:**
   ```bash
   go build -ldflags "-X="github.com/a-yerzhyk/kbot/cmd.appVersion=v1.0.2
   ```

## Configuration

Get a Telegram Bot Token and set it as an environment variable

## Usage

### Running the bot
```bash
./kbot kbot
```

### Bot functionality

Once the bot is running, you can interact with it on Telegram:

- Send `/start hello` to get a greeting message with the bot version
- The bot will respond to text messages based on the payload
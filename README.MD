# Crunchyroll Anime Release Notifier

## Description

This repository contains scripts to monitor Crunchyroll RSS feeds for new anime releases and notify users based on their preferences. The repository offers two implementations:

1. **A Bash script for Linux and Unix-based systems**: Includes support for cron jobs, multiple notification services, and dependency management.
2. **A PowerShell script for Windows systems**: Provides tray notifications using BurntToast, customizable intervals, and modular design.

Both implementations enable filtering by language dubs and series titles, ensuring tailored notifications for users.

## Features

### Common Features
- Filters anime releases by user-specified dubs.
- Supports notifications through:
  - Email
  - Pushover
  - IFTTT
  - Slack
  - Discord
  - Echo (Linux) / Tray Notifications (Windows).
- Customizable time intervals for checking RSS feeds.
- Logs activity and errors.

### Linux-Specific Features
- Cron job integration to reset the notification list daily.
- Dependency checks and installation via `bash`.

### Windows-Specific Features
- Windows tray notifications using BurntToast with clickable links to Crunchyroll.
- Modular PowerShell design with `.psd1` manifest files for easier maintenance.

## Requirements

### Linux
- `jq`
- `curl`
- `xmlstarlet`
- `bash`
- `cron`

### Windows
- PowerShell 5.0+
- BurntToast PowerShell module

## Installation

### Linux Installation
1. Clone repository ```bash
git clone https://github.com/Oratorian/crunchryroll_notify.gi
```
2. Ensure required tools are installed:
   ```bash
   ./crunchyroll-notify.sh
   ```
   The script will check and attempt to install missing dependencies.
3. Configure preferences in `./cfg/config.json`.

### Windows Installation
1. Download the script file from the [Releases](https://github.com/Oratorian/script-archive/releases).
2. Ensure the BurntToast module is installed:
   ```powershell
   Install-Module -Name BurntToast
   ```
3. Modify the `$userMediaIDs` array and other configurations within the script.

## Configuration

### Linux Configuration

Modify the `config.json` file to set your preferences:

```json
{
  "cron_time": "0 0 * * *",
  "anime": {
    "Example Anime": "ExampleDub",
  },
  "notification_services": {
    "email": false,
    "pushover": false,
    "ifttt": false,
    "slack": false,
    "discord": false,
    "echo": true
  },
  "announcerange": 60,
  "announced_file": "/tmp/announced_series_titles",
  "email_recipient": "your_email@example.com",
  "pushover": {
    "user_key": "your_pushover_user_key",
    "app_token": "your_pushover_app_token"
  },
  "ifttt": {
    "event": "your_ifttt_event",
    "key": "your_ifttt_key"
  },
  "slack": {
    "webhook_url": "https://hooks.slack.com/services/your/slack/webhook/url"
  },
  "discord": {
    "webhook_url": "https://discord.com/your/discord/channel/webhook/"
  },
  "debug": {
    "enabled": false
  }
}
```

### Windows Configuration

Modify the `config.json` file to set your preferences:
```{
    "userMediaIDs": {
        "Wistoria: Wand and Sword": "",
        "Tower of God": "",
        "Pseudo Harem": "",
        "The Misfit of Demon King Academy": "Spanish, Portuguese"
    },
    "announceRange": 60,
    "GlobalLogToFile": true,
    "GlobalDebug": false,
    "GlobalCheckInterval": 10,
    "announcedFile": "C:\\Temp\\announced_series_titles"
}```

## Running the Script

### Linux
```bash
./crunchyroll-notify.sh
```

Install a cron job for periodic checks:
```bash
(crontab -l; echo "*/15 * * * * /path/to/crunchyroll-notify.sh") | crontab -
```

### Windows
Run the PowerShell script:
```powershell
.CrunchyrollNotifier.ps1
```

Set up a scheduled task for periodic execution.

## Changelog

### [2.0.1] - 2024-09-27
#### Fixed
- Added `ModuleToProcess` field to `.psd1` manifest files to correctly link `.psm1` files.
- Specified module dependencies in the `.psd1` manifest files to ensure required modules are loaded or installed.

### [2.0.0] - 2024-09-26
#### Added
- Refactored the script into modular architecture.
- Implemented `.psd1` manifest files for better modularity and versioning.
- Integrated Semantic Versioning.

### [1.2.0] - 2024-09-26
#### Added
- Introduced `$checkInterval` for controlling RSS feed check intervals.
- Added `Confirm-IntervalWarning` for unsafe interval warnings.

#### Fixed
- Corrected dub filtering and series handling logic.

### [1.0.0 - 1.1.1] - Initial release with features for RSS feed parsing and tray notifications.

## License

This project is licensed under the GPL-3.0 License. See the `LICENSE` file for details.

---

**Author**: Oration 'Mahesvara'  
**GitHub**: [Oratorian@github.com](https://github.com/Oratorian)

#!/bin/bash

check_config() {
  local config_path="$SCRIPT_DIR/cfg/config.json"
  local default_config='{
    "cron_time": "0 0 * * *",
    "animes": {
      "Example Anime": "ExampleDub"
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
  }'

  [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Checking if config file exists at: $config_path"

  if [ ! -f "$config_path" ]; then
    log "INFO" "Config file not found. Creating default config at $config_path..."
    [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Config file not found. Creating default config at $config_path..."
    mkdir -p "$SCRIPT_DIR/cfg"
    echo "$default_config" >"$config_path"
    log "INFO" "Default config created. Please edit the config before running the script again."
    [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Default config created. Please edit the config before running the script again."
    exit 1
  fi

  [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Config file exists. Checking for 'Example Anime' in config."

  if [[ -n "${user_media_ids["Example Anime"]}" ]]; then
    log "ERROR" "'Example Anime' is still present in the config. Please update your config before running the script."
    exit 1
  fi

  local updated_config
  updated_config=$(jq -n --argfile default <(echo "$default_config") --argfile user "$config_path" '
    $default as $d | $user as $u |
    $d * $u  # Merge default and user config; user config overwrites defaults
    | .animes = if ($u.animes // {} | length) > 0 then $u.animes else $d.animes end  # Preserve user animes if not empty
  ')

  if [ "$updated_config" != "$(cat "$config_path")" ]; then
    log "INFO" "Config file was missing some keys. Adding missing keys..."
    echo "$updated_config" >"$config_path"
    log "INFO" "Config updated with missing keys."
  fi

  [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Config file validated and updated if necessary."
}

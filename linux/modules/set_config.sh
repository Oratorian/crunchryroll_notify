log "INFO" "Setting configuration values from config.json"
get_media_array "animes"
announced_file=$(get_config "announced_file")
announcerange=$(get_config "announcerange")
cron_time=$(get_config "cron_time")
notify_discord=$(get_config "notification_services.discord")
notify_echo=$(get_config "notification_services.echo")
notify_slack=$(get_config "notification_services.slack")
notify_ifttt=$(get_config "notification_services.ifttt")
notify_email=$(get_config "notification_services.email")
notify_pushover=$(get_config "notification_services.pushover")
DEBUG_ENABLED=$(get_config "debug.enabled")
[ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Setting configuration values from config.json"
declare -A ANNOUNCED_TITLES
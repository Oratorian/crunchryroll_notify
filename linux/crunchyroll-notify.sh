#!/bin/bash

#---------------------------------------------------------------------------------------------
# This script © 2024 by Oration 'Mahesvara' is released unter the GPL-3.0 license
# Reproduction and modifications are allowed as long as I Oratorian@github.com is credited
# as the original Author
#---------------------------------------------------------------------------------------------

## Version: 2.3.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Script directory set to $SCRIPT_DIR"

for module in $SCRIPT_DIR/modules/*.sh; do
    if [ -f "$module" ]; then
        [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Attempting to source module: $module"
        if source "$module"; then
            [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Successfully sourced module: $module"
        else
            log "ERROR" "Failed to source module: $module. Exiting."
            exit 1
        fi
    else
        log "ERROR" "Module file $module not found. Exiting."
        exit 1
    fi
done

check_config
[ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Checked configuration."

check_system_requirements
[ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Checked system requirements."

install_cron_job
[ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Installed cron job."

[ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Checking logrotate.d configuration."
install_logrotate_for_crunchyroll_notify

if [ -n "$announced_file" ] && [ -f "$announced_file" ]; then
    [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Loading announced titles from file: $announced_file"
    while IFS= read -r line; do
        ANNOUNCED_TITLES["$line"]=1
    done <"$announced_file"
else
    log "ERROR" "announced_file is not set or does not exist."
    check_announced_file
fi

rss_feed=$(curl -sL "https://www.crunchyroll.com/rss/calendar?time=$(date +%s)")
[ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Fetched RSS feed."

if ! echo "$rss_feed" | grep -q "<?xml"; then
    log "ERROR" "The fetched content is not valid XML."
    exit 1
fi

media_items=$(echo "$rss_feed" | xmlstarlet sel -N cr="http://www.crunchyroll.com/rss" -N media="http://search.yahoo.com/mrss/" -t -m "//item" -v "concat(crunchyroll:seriesTitle, '|', title, '|', pubDate, '|', link, '|', normalize-space(description), '|', media:thumbnail[1]/@url)" -n)
[ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Parsed media items from RSS feed."

while IFS= read -r line; do
    series_title=$(echo "$line" | cut -d'|' -f1)
    title=$(echo "$line" | cut -d'|' -f2)
    pub_date=$(echo "$line" | cut -d'|' -f3)
    link=$(echo "$line" | cut -d'|' -f4)
    description=$(echo "$line" | cut -d'|' -f5)
    thumbnail_url=$(echo "$line" | cut -d'|' -f6)
    lower_series_title=$(echo "$title" | tr '[:upper:]' '[:lower:]')
    allowed_dubs="${user_media_ids["$series_title"]}"

    found_match=false
    for user_title in "${!user_media_ids[@]}"; do
        lower_user_title=$(echo "$user_title" | tr '[:upper:]' '[:lower:]')
        if [[ "$lower_series_title" == "$lower_user_title"* ]]; then
            found_match=true
            break
        fi
    done

    [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Processing series: $title"

    if [ "$found_match" = false ]; then
        [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Skipping series: $series_title as it is not listed in user_media_ids"
        continue
    fi

    if is_allowed_dub "$lower_series_title" "$allowed_dubs"; then
        [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Series $series_title has allowed dubs."

        if ! is_within_time_range "$pub_date" "$announcerange"; then
            [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Series $series_title is not within the announcement time range."
            continue
        fi

        if ! is_title_announced "$lower_series_title"; then
            [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Announcing new title: $series_title"
            log "INFO" "Announcing new title: $series_title"
            [ "$notify_email" = true ] && notify_via_email "$series_title"
            [ "$notify_pushover" = true ] && notify_via_pushover "$series_title"
            [ "$notify_ifttt" = true ] && notify_via_ifttt "$series_title"
            [ "$notify_slack" = true ] && notify_via_slack "$series_title"
            [ "$notify_discord" = true ] && notify_via_discord "$series_title" "$title" "$link" "$description" "$thumbnail_url"
            [ "$notify_echo" = true ] && notify_via_echo "$series_title" "$title" "$link" "$description" "$thumbnail_url"
            add_title_to_announced "$lower_series_title"
        fi
    else
        [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Series $series_title has no allowed dubs."
        continue
    fi
done <<<"$(echo "$media_items" | tr -d '\r')"

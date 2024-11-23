#!/bin/bash

clean_description() {
    [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Cleaning description"
    echo "$1" | sed -E 's/<img[^>]*>//g; s/<br \/>//g; s/&#13;//g' | tr -d '
'
}

decode_html_entities() {
    [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Encoding HTML entities"
    echo "$1" | xmlstarlet unescape
}

add_title_to_announced() {
    [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Adding '$1' to announced file"
    local title="$1"
    echo "$title" >>"$announced_file"
    ANNOUNCED_TITLES["$title"]=1
}

check_announced_file() {
    if [ -z "$announced_file" ]; then
        [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "No file path returned for 'announced_file' in config."
        log "ERROR" "No file path returned for 'announced_file' in config."
        exit 1
    fi

    if [ ! -f "$announced_file" ]; then
        touch "$announced_file"
        [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Created announced file at $announced_file."
        log "INFO" "Created announced file at $announced_file."
    else
        [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Announced file already exists at $announced_file."
        log "INFO" "Announced file already exists at $announced_file."
    fi
}

is_within_time_range() {
    local pub_date="$1"
    local range_in_minutes="$2"

    pub_date_seconds=$(date --date="$pub_date" +%s)
    current_time_seconds=$(date -u +%s)
    time_difference=$((current_time_seconds - pub_date_seconds))
    range_in_seconds=$((range_in_minutes * 60))

    if ((time_difference <= range_in_seconds && time_difference >= -range_in_seconds)); then
        return 0
    else
        return 1
    fi
}

is_title_announced() {
    local keyword="$1"
    for announced_title in "${!ANNOUNCED_TITLES[@]}"; do
        if [[ "$announced_title" == *"$keyword"* ]]; then
            return 0
            [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Title already announced"
        fi
    done
    return 1
}

is_allowed_dub() {
    local title="$1"
    local allowed_dubs="$2"
    local lower_title=$(echo "$title" | tr '[:upper:]' '[:lower:]')
    [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Checking '$1' for allowed DUBS."

    series_name=$(echo "$lower_title" | sed 's/(.*dub)//g' | sed 's/ - episode.*//g' | sed 's/ *$//')

    if ! [[ "$lower_title" =~ \(.*[Dd]ub\) ]]; then
        return 0
        [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "No DUBS set, defaulting to Japanese"
    fi

    if [[ -z "$allowed_dubs" ]]; then
        return 1
    fi

    IFS=',' read -r -a allowed_dubs_array <<<"$allowed_dubs"
    for dub in "${allowed_dubs_array[@]}"; do

        if [[ "$lower_title" == *"$(echo "$dub" | tr '[:upper:]' '[:lower:]')"*"dub"* ]]; then
            return 0
            [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "DUBS set, using '$dub'"
        fi
    done

    return 1
}

install_logrotate_for_crunchyroll_notify() {
    local logrotate_config_path="/etc/logrotate.d/crunchyroll-notify"

    if [ -d "/etc/logrotate.d" ]; then
        [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Detected Debian-based system. Installing logrotate configuration in /etc/logrotate.d"
        cat <<EOL | sudo tee "$logrotate_config_path" >/dev/null
/var/log/crunchyroll-notify.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 root adm
}
EOL
    elif [ -d "/usr/local/etc/logrotate.d" ]; then
        [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Detected FreeBSD system. Installing logrotate configuration in /usr/local/etc/logrotate.d"
        logrotate_config_path="/usr/local/etc/logrotate.d/crunchyroll-notify"
        cat <<EOL | sudo tee "$logrotate_config_path" >/dev/null
/var/log/crunchyroll-notify.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 root adm
}
EOL
    else
        log "ERROR" "Unsupported system. Please manually configure logrotate for /var/log/crunchyroll-notify.log"
        return 1
    fi

    [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Logrotate configuration installed at $logrotate_config_path"
}
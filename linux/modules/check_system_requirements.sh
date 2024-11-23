#!/bin/bash

install_package() {
    local package="$1"
    if [ -x "$(command -v apt)" ]; then
        sudo apt update && sudo apt install -y "$package"
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install -y "$package"
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install -y "$package"
    elif [ -x "$(command -v pacman)" ]; then
        sudo pacman -Sy --noconfirm "$package"
    elif [ -x "$(command -v zypper)" ]; then
        sudo zypper install -y "$package"
    elif [ -x "$(command -v brew)" ]; then
        brew install "$package"
    else
        [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Unsupported OS or package manager. Please install $package manually."
        log "ERROR" "Unsupported OS or package manager. Please install $package manually."
        exit 1
    fi
}

check_system_requirements() {
    local missing=false
    for tool in curl jq xmlstarlet cron bash grep sed cut date; do
        if ! command -v "$tool" &>/dev/null; then
            [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "$tool is not installed. Attempting to install it."
            log "ERROR" "$tool is not installed. Attempting to install it."
            install_package "$tool"
            if ! command -v "$tool" &>/dev/null; then
                [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "$tool is not installed. Attempting to install it."
                log "INFO" "$tool is not installed. Attempting to install it."
                missing=true
            fi
        fi
    done

    if [ "$missing" = true ]; then
        [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Some dependencies could not be installed. Please install them manually."
        log "ERROR" "Some dependencies could not be installed. Please install them manually."
        exit 1
    else
        [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "All required tools are installed."
        log "INFO" "All required tools are installed."
    fi
}

install_cron_job() {
    local cron_job="$cron_time > $announced_file"
    local cron_exists=$(crontab -l 2>/dev/null | grep -F "$cron_job")

    if [ -z "$cron_exists" ]; then
        crontab -l 2>/dev/null | grep -v "$announced_file" | crontab -
        (
            crontab -l 2>/dev/null
            echo "$cron_job"
        ) | crontab -
        [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Cron job installed to empty the announced file daily at $cron_time."
        log "INFO" "Cron job installed to empty the announced file daily at $cron_time."
    else
        [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Cron job already exists and is up to date."
        log "INFO" "Cron job already exists and is up to date."
    fi
}

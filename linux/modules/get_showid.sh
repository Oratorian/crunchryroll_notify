#!/bin/bash

extract_video_id() {
    local link="$1"
    local video_id

    video_id=$(echo "$link" | sed -n 's#.*/watch/\([^/]*\)/.*#\1#p')

    [ "$DEBUG_ENABLED" = true ] && log "DEBUG" "Video ID is: $video_id"
    echo "$video_id"
}
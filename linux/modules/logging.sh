log() {
    local loglevel="$1"
    shift
    local message="$*"
    local timestamp="$(date "+%Y-%m-%d %H:%M:%S")"

    case "$loglevel" in
    "ERROR")
        echo -e "\e[31m[$timestamp] [ERROR] $message\e[0m"
        echo -e "[$timestamp] [ERROR] $message" >>/var/log/crunchyroll-notify.log
        ;;
    "INFO")
        echo -e "\e[33m[$timestamp] [INFO] $message\e[0m"
        echo -e "[$timestamp] [INFO] $message" >>/var/log/crunchyroll-notify.log
        ;;
    "DEBUG")
        echo -e "\e[34m[$timestamp] [DEBUG] $message\e[0m"
        echo -e "[$timestamp] [DEBUG] $message" >>/var/log/crunchyroll-notify.log
        ;;
    *)
        echo "[$timestamp] [UNKNOWN] $message" >>/var/log/crunchyroll-notify.log
        ;;
    esac
}

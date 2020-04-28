#!/bin/sh

main() {
    if ! [ -f ~/.config/polybar/scripts/toggl_key ]; then
        echo ""
        exit
    fi

    api_token=$(cat ~/.config/polybar/scripts/toggl_key)
    api_url="https://www.toggl.com/api/v8/time_entries/current"

    result=$(curl -su $api_token:api_token -X GET $api_url)

    if [ "$(echo $result | jq -r '.data')" = "null" ]; then
        echo ""
        exit
    fi

    start_date=$(echo $result | jq -r '.data.start')
    description=$(echo $result | jq -r '.data.description')

    # if [[ ! -z $result ]]; then
    #     echo ""
    #     exit
    # fi

    diff=$(($(date "+%s") - $(date -d $start_date "+%s")))

    duration=$(printf '%dh:%dm\n' $(($diff / 3600)) $(($diff % 3600 / 60)))

    echo "${*:-%duration% - %description%}" | sed "s/%duration%/$duration/g;s/%description%/$description/g"i | sed 's/&/\\&/g'
}

main "$@"

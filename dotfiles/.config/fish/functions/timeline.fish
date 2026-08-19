function timeline --description 'Lista os eventos da timeline do $FREIGHT_ID'
    curl -s "http://localhost:8080/api/v2/company/offers/$FREIGHT_ID/timeline" \
            -H "Authorization: Bearer $TOKEN" \
          | jq '[.data.days[].events[] | {type, title, source_id, origin: .origin.value, person: .origin.person.name, has_details}]'
end

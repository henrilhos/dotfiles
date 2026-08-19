function detail --description 'Detalhe de um evento: detail <type> <source_id>'
    curl -s "http://localhost:8080/api/v2/company/offers/$FREIGHT_ID/timeline/$argv[1]/$argv[2]/details" \
            -H "Authorization: Bearer $TOKEN" | jq '.data.sections'
end

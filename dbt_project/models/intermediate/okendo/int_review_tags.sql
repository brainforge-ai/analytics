SELECT
    reviewid AS review_id,
    value::string AS value
FROM {{ source('portable_okendo','reviews') }},
    LATERAL flatten(input => tags)
WHERE tags != 'null'

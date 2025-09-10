WITH flattened_values AS (
    SELECT
        reviewid AS review_id,
        lower(value:TITLE::string) AS title,
        CASE
            WHEN
                value:VALUE::string LIKE '[%'
                THEN array_to_string(try_parse_json(value:VALUE::string), ', ')
            ELSE value:VALUE::string
        END AS value
    FROM {{ source('portable_okendo','reviews') }},
        LATERAL flatten(input => productattributes)
    WHERE productattributes != 'null'
)

SELECT
    review_id,
    max(
        CASE
            WHEN title = 'do you use dummyclient everyday?' THEN value
        END
    ) AS use_dummyclient_everyday,
    max(
        CASE
            WHEN title = 'taste' THEN value
        END
    ) AS product_taste_feedback,
    max(
        CASE
            WHEN title = 'how often do you use dummyclient?' THEN value
        END
    ) AS dummyclient_usage_frequency,
    max(
        CASE
            WHEN title = 'shipping' THEN value
        END
    ) AS shipping_feedback
FROM flattened_values
GROUP BY review_id

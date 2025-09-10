WITH
    flattened_data AS (
        SELECT
            reviewid AS review_id,
            value:
        TYPE::string AS
        TYPE,
        value:ISHIDDEN::boolean AS is_hidden
        FROM
            {{ source('portable_okendo','reviews') }},
            LATERAL FLATTEN(input => media)
        WHERE
            media != 'null'
    )
SELECT
    review_id,
    SUM(
        CASE
            WHEN LOWER(
                TYPE
            ) = 'image' THEN 1
            ELSE 0
        END
    ) AS number_of_images,
    SUM(
        CASE
            WHEN LOWER(
                TYPE
            ) = 'video' THEN 1
            ELSE 0
        END
    ) AS number_of_videos,
    SUM(
        CASE
            WHEN LOWER(
                TYPE
            ) = 'audio' THEN 1
            ELSE 0
        END
    ) AS number_of_audio_files,
    COUNT(*) AS total_media_count
FROM
    flattened_data
WHERE
    COALESCE(is_hidden, FALSE) = FALSE -- Exclude hidden media
GROUP BY
    ALL
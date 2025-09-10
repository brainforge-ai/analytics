with first_agent_response AS (
    SELECT
        m.ticket_id,
        MIN(m.created_datetime) AS first_agent_response_datetime
    FROM {{ ref('raw_gorgias_messages') }} m
    WHERE m.IS_FROM_AGENT = TRUE
    GROUP BY m.ticket_id
),

first_customer_message AS (
    SELECT
        m.ticket_id,
        MIN(m.created_datetime) AS first_customer_message_datetime
    FROM {{ ref('raw_gorgias_messages') }} m
    WHERE m.IS_FROM_AGENT = FALSE
    GROUP BY m.ticket_id
),

first_response_time AS (
    SELECT
        fcm.ticket_id,
        TIMEDIFF(
            'second',
            fcm.first_customer_message_datetime,
            far.first_agent_response_datetime
        ) AS first_response_time_seconds,
        TIMEDIFF(
            'hour',
            fcm.first_customer_message_datetime,
            far.first_agent_response_datetime
        ) AS first_response_time_hours,
        DATEDIFF(
            'day',
            fcm.first_customer_message_datetime,
            far.first_agent_response_datetime
        ) AS first_response_time_days
    FROM first_customer_message fcm
    LEFT JOIN first_agent_response far ON fcm.ticket_id = far.ticket_id
),

ticket_details AS (
    SELECT
        t.ticket_id,
        t.created_datetime AS ticket_created_datetime,
        t.closed_datetime AS ticket_closed_datetime,
        t.status
    FROM {{ ref('raw_gorgias_tickets') }} t
),

final AS (
    SELECT
        td.ticket_id,
        status,
        td.ticket_created_datetime,
        ticket_closed_datetime,
        COALESCE(TIMEDIFF('second', td.ticket_created_datetime, td.ticket_closed_datetime), NULL) AS time_to_resolution_seconds,
        COALESCE(TIMEDIFF('hour', td.ticket_created_datetime, td.ticket_closed_datetime), NULL) AS time_to_resolution_hours,
        COALESCE(DATEDIFF('day', td.ticket_created_datetime, td.ticket_closed_datetime), NULL) AS time_to_resolution_days,
        CASE
            WHEN td.status != 'closed' THEN TIMEDIFF('second', td.ticket_created_datetime, CURRENT_TIMESTAMP)
        END AS ticket_age_seconds,
        CASE
            WHEN td.status != 'closed' THEN TIMEDIFF('hour', td.ticket_created_datetime, CURRENT_TIMESTAMP)
        END AS ticket_age_hours,
        CASE
            WHEN td.status != 'closed' THEN datediff('day', td.ticket_created_datetime, CURRENT_TIMESTAMP)
        END AS ticket_age_days,
        frt.first_response_time_seconds,
        frt.first_response_time_hours,
        frt.first_response_time_days
    FROM ticket_details td
    LEFT JOIN first_response_time frt ON td.ticket_id = frt.ticket_id
)
SELECT * FROM final

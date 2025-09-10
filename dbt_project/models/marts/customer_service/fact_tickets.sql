WITH ticket_data AS (
    SELECT 
        t.TICKET_ID,
        t.AGENT_ID,
        a.AGENT_FULL_NAME AS AGENT_NAME,
        s.CREATED_DATETIME as SATISFACTION_SURVEY_CREATED_DATETIME,
        s.BODY_TEXT as SATISFACTION_SURVEY_BODY_TEXT,
        s.CUSTOMER_ID as SATISFACTION_SURVEY_CUSTOMER_ID,
        s.SURVEY_ID as SATISFACTION_SURVEY_ID,
        s.SCORE as SATISFACTION_SURVEY_SCORE,
        s.SCORED_DATETIME as SATISFACTION_SURVEY_SCORED_DATETIME,
        s.SENT_DATETIME as SATISFACTION_SURVEY_SENT_DATETIME,
        s.SHOULD_SEND_DATETIME as SATISFACTION_SURVEY_SHOULD_SEND_DATETIME,
        array_agg(dm.MACRO_NAME) as MACRO_NAMES,
        CASE WHEN s.SCORED_DATETIME IS NOT NULL THEN TRUE ELSE FALSE END AS CUSTOMER_LEFT_SCORE,
        CASE WHEN s.BODY_TEXT IS NOT NULL THEN TRUE ELSE FALSE END AS CUSTOMER_LEFT_REVIEW,
        MAX(CASE WHEN rf.FIELD_LABEL = 'Reason' THEN rf.FIELD_VALUE ELSE NULL END) AS REASON,
        MAX(CASE WHEN rf.FIELD_LABEL = 'Old Reason' THEN rf.FIELD_VALUE ELSE NULL END) AS OLD_REASON,
        MAX(CASE WHEN rf.FIELD_LABEL = 'Action' THEN rf.FIELD_VALUE ELSE NULL END) AS ACTION,
        MAX(CASE WHEN rf.FIELD_LABEL = 'Additional Info' THEN rf.FIELD_VALUE ELSE NULL END) AS ADDITIONAL_INFO,
        MAX(CASE WHEN rf.FIELD_LABEL = 'Contact Reason' THEN rf.FIELD_VALUE ELSE NULL END) AS CONTACT_REASON,
        MAX(CASE WHEN rf.FIELD_LABEL = 'Exception Approved ✨' THEN rf.FIELD_VALUE ELSE NULL END) AS EXCEPTION_APPROVED,
        MAX(CASE WHEN rf.FIELD_LABEL = 'Save Offered' THEN rf.FIELD_VALUE ELSE NULL END) AS SAVE_OFFERED,
        MAX(CASE WHEN rf.FIELD_LABEL = 'Full Refund' THEN rf.FIELD_VALUE ELSE NULL END) AS FULL_REFUND,
        t.CLOSED_DATETIME,
        t.CREATED_DATETIME,
        t.LAST_MESSAGE_DATETIME,
        t.LAST_RECEIVED_MESSAGE_DATETIME,
        t.MESSAGES_COUNT,
        t.OPENED_DATETIME,
        t.SPAM,
        t.CHANNEL,
        t.CUSTOMER_ID,
        t.CUSTOMER_EMAIL,
        t.CUSTOMER_NAME,
        t.VIA,
        t.TAG_NAMES,
        frt.first_response_time_seconds,
        frt.first_response_time_hours,
        frt.first_response_time_days,
        frt.time_to_resolution_seconds,
        frt.time_to_resolution_hours,
        frt.time_to_resolution_days,
        frt.ticket_age_seconds,
        frt.ticket_age_hours,
        frt.ticket_age_days
    FROM {{ ref('raw_gorgias_tickets') }} t
    LEFT JOIN {{ ref('dim_agents') }} a
        ON t.AGENT_ID = a.AGENT_ID
    LEFT JOIN {{ ref('raw_gorgias_satisfaction_surveys') }} s
        ON t.TICKET_ID = s.TICKET_ID
    LEFT JOIN {{ ref('fact_messages')}} m
        ON t.TICKET_ID = m.TICKET_ID
    LEFT JOIN {{ ref('dim_macros')}} dm
        ON m.MACRO_ID = dm.MACRO_ID
    LEFT JOIN {{ ref('raw_gorgias_ticket_fields') }} rf
        ON t.TICKET_ID = rf.TICKET_ID
    LEFT JOIN {{ ref('int_response_times') }} frt
        ON t.TICKET_ID = frt.ticket_id
    GROUP BY ALL
)

-- Final selection with additional fields
SELECT 
    td.TICKET_ID,
    td.CUSTOMER_ID,
    td.CUSTOMER_EMAIL,
    td.CUSTOMER_NAME,
    td.AGENT_NAME,
    td.AGENT_ID,
    td.SATISFACTION_SURVEY_CREATED_DATETIME,
    td.SATISFACTION_SURVEY_BODY_TEXT,
    td.SATISFACTION_SURVEY_CUSTOMER_ID,
    td.SATISFACTION_SURVEY_ID,
    td.SATISFACTION_SURVEY_SCORE,
    td.SATISFACTION_SURVEY_SCORED_DATETIME,
    td.SATISFACTION_SURVEY_SENT_DATETIME,
    td.SATISFACTION_SURVEY_SHOULD_SEND_DATETIME,
    td.MACRO_NAMES,
    CASE WHEN ARRAY_SIZE(td.MACRO_NAMES) > 0 THEN TRUE ELSE FALSE END AS MACRO_USED,
    td.CUSTOMER_LEFT_SCORE,
    td.CUSTOMER_LEFT_REVIEW,
    td.REASON,
    td.OLD_REASON,
    td.ACTION,
    td.ADDITIONAL_INFO,
    td.CONTACT_REASON,
    td.EXCEPTION_APPROVED,
    td.SAVE_OFFERED,
    td.FULL_REFUND,
    td.CLOSED_DATETIME,
    td.CREATED_DATETIME,
    td.LAST_MESSAGE_DATETIME,
    td.LAST_RECEIVED_MESSAGE_DATETIME,
    td.MESSAGES_COUNT,
    td.OPENED_DATETIME,
    td.SPAM,
    td.CHANNEL,
    td.VIA,
    td.TAG_NAMES,
    td.first_response_time_seconds,
    td.first_response_time_hours,
    td.first_response_time_days,
    td.time_to_resolution_seconds,
    td.time_to_resolution_hours,
    td.time_to_resolution_days,
    td.ticket_age_seconds,
    td.ticket_age_hours,
    td.ticket_age_days,
    CASE WHEN td.TICKET_ID IS NOT NULL THEN TRUE ELSE FALSE END AS SEND_SURVEY,
    CASE WHEN td.AGENT_ID IS NOT NULL THEN TRUE ELSE FALSE END AS AGENT_ASSIGNED
FROM ticket_data td
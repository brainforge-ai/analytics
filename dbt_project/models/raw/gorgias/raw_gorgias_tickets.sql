-- models\raw\gorgias\raw_gorgias_tickets.sql
-- small clean up
-- all variant/json columns are still encapsulated here, just agent FK was extracted

SELECT  
    ID AS TICKET_ID,
    customer:ID::varchar AS CUSTOMER_ID,
    TRIM(customer:EMAIL, '""') AS CUSTOMER_EMAIL,
    customer:FIRSTNAME || ' ' || customer:LASTNAME AS CUSTOMER_NAME,
    ASSIGNEE_USER:ID::INT AS AGENT_ID, -- Assignee details extracted from JSON (FK)
    CHANNEL,
    CLOSED_DATETIME,
    CREATED_DATETIME,
    LAST_MESSAGE_DATETIME,
    LAST_RECEIVED_MESSAGE_DATETIME,
    MESSAGES_COUNT,
    OPENED_DATETIME,
    PRIORITY,
    SNOOZE_DATETIME,
    SPAM,
    STATUS,
    SUBJECT,
    TRASHED_DATETIME,
    UPDATED_DATETIME,
    URI,
    VIA,
    ARRAY_AGG(tag.value:NAME::STRING) AS TAG_NAMES
FROM raw.portable_gorgias.tickets,
LATERAL FLATTEN(input => TAGS) AS tag
WHERE CHANNEL NOT IN ('phone', 'sms')  -- Filtering out phone and SMS channels as requested by dummyclient
GROUP BY ALL
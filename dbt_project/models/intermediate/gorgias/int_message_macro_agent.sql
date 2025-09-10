-- models\int\gorgias\int_message_macro_agent.sql

-- messages source table with exploded macro information as well as agent information
-- (e.g., which messages used which macros and which agent handled the ticket)
-- models\int\gorgias\int_message_macro_agent.sql

-- Messages source table with exploded macro information as well as agent information
-- (e.g., which messages used which macros and which agent handled the ticket)
WITH MACROS_EXPLODED AS (
    SELECT 
        MESSAGES_ID,
        ACTIONS,
        ATTACHMENTS,
        BODY_HTML,
        BODY_TEXT,
        CHANNEL,
        CREATED_DATETIME,
        EXTERNAL_ID,
        FAILED_DATETIME,
        IS_FROM_AGENT,
        INTEGRATION_ID,
        INTENTS,
        IS_RETRIABLE,
        LAST_SENDING_ERROR,
        MACRO_ID,  -- Already exploded in raw_gorgias_messages_macros
        MESSAGE_ID,
        OPENED_DATETIME,
        IS_PUBLIC,
        RECEIVER,
        RULE_ID,
        SENDER,
        SENT_DATETIME,
        SOURCE,
        STRIPPED_HTML,
        STRIPPED_SIGNATURE,
        STRIPPED_TEXT,
        SUBJECT,
        TICKET_ID,
        URI,
        VIA
    FROM {{ ref('raw_gorgias_messages_macros') }}
)
SELECT
    ME.*,
    AGENT_ID
FROM MACROS_EXPLODED AS ME
LEFT JOIN {{ ref('raw_gorgias_tickets') }} t
    ON ME.TICKET_ID = t.TICKET_ID
WHERE AGENT_ID IS NOT NULL
ORDER BY ME.TICKET_ID, ME.MESSAGES_ID
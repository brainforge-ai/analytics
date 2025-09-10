
-- models\raw\gorgias\raw_gorgias_messages.sql
-- small clean up
-- all variant/json columns are still encapsulated here

SELECT 
    ID::varchar AS MESSAGES_ID,
    ACTIONS,
    ATTACHMENTS,
    BODY_HTML,
    BODY_TEXT,
    CHANNEL,
    CREATED_DATETIME,
    EXTERNAL_ID,
    FAILED_DATETIME,
    FROM_AGENT AS IS_FROM_AGENT,
    INTEGRATION_ID,
    INTENTS,
    IS_RETRIABLE,
    LAST_SENDING_ERROR,
    MACROS,
    MESSAGE_ID::varchar AS MESSAGE_ID,
    OPENED_DATETIME,
    PUBLIC AS IS_PUBLIC,
    RECEIVER,
    RULE_ID::varchar AS RULE_ID,
    SENDER,
    SENT_DATETIME,
    SOURCE,
    STRIPPED_HTML,
    STRIPPED_SIGNATURE,
    STRIPPED_TEXT,
    SUBJECT,
    TICKET_ID::varchar AS TICKET_ID,
    URI,
    VIA
FROM {{ source('portable_gorgias','messages') }}


-- models\raw\gorgias\raw_gorgias_messages_macros.sql
-- small clean up
-- the MACROS variant/json columns was unflattened here

SELECT 
    m.ID AS MESSAGES_ID,
    m.ACTIONS,
    m.ATTACHMENTS,
    m.BODY_HTML,
    m.BODY_TEXT,
    m.CHANNEL,
    m.CREATED_DATETIME,
    m.EXTERNAL_ID,
    m.FAILED_DATETIME,
    m.FROM_AGENT AS IS_FROM_AGENT,
    m.INTEGRATION_ID,
    m.INTENTS,
    m.IS_RETRIABLE,
    m.LAST_SENDING_ERROR,
    f.VALUE:ID::NUMBER AS MACRO_ID,  -- Extract MACRO_ID from JSON array
    m.MESSAGE_ID,
    m.OPENED_DATETIME,
    m.PUBLIC AS IS_PUBLIC,
    m.RECEIVER,
    m.RULE_ID,
    m.SENDER,
    m.SENT_DATETIME,
    m.SOURCE,
    m.STRIPPED_HTML,
    m.STRIPPED_SIGNATURE,
    m.STRIPPED_TEXT,
    m.SUBJECT,
    m.TICKET_ID,
    m.URI,
    m.VIA
FROM {{ source('portable_gorgias','messages') }} AS m,
LATERAL FLATTEN(INPUT => m.MACROS) AS f  -- Flatten the MACROS array

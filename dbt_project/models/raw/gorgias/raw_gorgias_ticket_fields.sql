-- models\raw\gorgias\raw_ticket_fields.sql
-- small clean up
-- the CUSTOM_FIELDS variant/json columns was unflattened here

SELECT 
    TICKET_ID,
    KEY::STRING AS CUSTOM_FIELD_ID,                        -- Extract the outer key (e.g., "_120")
    VALUE:FIELD:ID::STRING AS FIELD_ID,                    -- Extract the inner ID inside FIELD
    VALUE:FIELD:LABEL::STRING AS FIELD_LABEL,              -- Extract the field LABEL (e.g., "Old Reason")
    VALUE:FIELD:DESCRIPTION::STRING AS FIELD_DESCRIPTION,  -- Extract field DESCRIPTION
    VALUE:VALUE::STRING AS FIELD_VALUE,                    -- Extract the VALUE of the field (e.g., "Damaged Order")
    UPDATED_DATETIME
FROM {{ source('portable_gorgias','ticket_details') }},
LATERAL FLATTEN(INPUT => CUSTOM_FIELDS)
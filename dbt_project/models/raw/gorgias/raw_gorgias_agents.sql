-- models\raw\gorgias\raw_agents.sql

-- Stores agent/users information
SELECT 
    ID AS AGENT_ID,
    FIRSTNAME AS AGENT_FIRST_NAME,
    LASTNAME AS AGENT_LAST_NAME,
    NAME AS AGENT_FULL_NAME,
    EMAIL AS AGENT_EMAIL,
    ROLE:NAME::STRING AS AGENT_ROLE,  -- Extract the field NAME from the ROLE column (e.g., "admin")
    TIMEZONE AS AGENT_TIMEZONE,
    CREATED_DATETIME,
    UPDATED_DATETIME,
    ACTIVE,
    BIO AS AGENT_BIO,
    META:PROFILE_PICTURE_URL::STRING AS AGENT_PROFILE_PICTURE_URL
FROM {{ source('portable_gorgias','users') }}
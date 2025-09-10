-- models\marts\customer_service\dim_agents.sql

SELECT 
    AGENT_ID,
    AGENT_FIRST_NAME,
    AGENT_LAST_NAME,
    AGENT_FULL_NAME,
    AGENT_EMAIL,
    AGENT_ROLE,     -- Extracted from the field NAME from the ROLE column (e.g., "admin")
    AGENT_TIMEZONE,
    CREATED_DATETIME,
    UPDATED_DATETIME,
    ACTIVE,
    AGENT_BIO,
    AGENT_PROFILE_PICTURE_URL
FROM {{ ref('raw_gorgias_agents') }}
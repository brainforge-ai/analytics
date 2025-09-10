-- models\marts\customer_service\agent_macro_usage_summary.sql

SELECT 
    da.AGENT_FULL_NAME, 
    da.AGENT_ID,  -- adding agent_id (FK) to the dim_agents table
    da.AGENT_ROLE,
    da.AGENT_EMAIL,
    dm.MACRO_NAME,  
    COUNT(DISTINCT imma.MESSAGES_ID) AS USAGE_COUNT  -- Count messages, not tickets
FROM {{ ref('int_message_macro_agent') }} as imma  
LEFT JOIN {{ ref('dim_agents') }} da  
    ON imma.AGENT_ID = da.AGENT_ID  
LEFT JOIN {{ ref('dim_macros') }} dm  
    ON imma.MACRO_ID = dm.MACRO_ID  
GROUP BY da.AGENT_FULL_NAME, da.AGENT_ID, da.AGENT_ROLE, da.AGENT_EMAIL, dm.MACRO_NAME  
ORDER BY da.AGENT_FULL_NAME, USAGE_COUNT DESC


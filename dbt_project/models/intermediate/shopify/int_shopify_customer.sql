
WITH ADDRESS AS (

    SELECT
        CUSTOMER_ID,
        ADDRESS_1,
        ADDRESS_2,
        CITY,
        COUNTRY,
        COUNTRY_CODE,
        PROVINCE,
        PROVINCE_CODE,
        ZIP,
        CASE WHEN REGEXP_LIKE(ZIP,'^[0-9]+(-[0-9]+)+$') = TRUE THEN LEFT(TRIM(ZIP),5) ELSE ZIP END AS ZIP_CLEANED,
        TRIM(ADDRESS_1)||' '||TRIM(IFNULL(ADDRESS_2,''))||', '||TRIM(CITY)||' '||TRIM(PROVINCE_CODE)||', '||TRIM(ZIP) AS FULL_ADDRESS
    FROM {{ ref('raw_shopify_customer_addresses')}}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID ORDER BY CREATED_AT DESC) = 1

),

SUB AS (

    SELECT
        CUSTOMER_ID,
        TAG
    FROM {{ref('raw_shopify_customer_tags')}}
    WHERE TAG in ('Active Subscriber','Past Subscriber')
    QUALIFY ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID ORDER BY TAG ASC) = 1

),

ORDER_DATES AS (

    SELECT
        CUSTOMER_ID,
        MIN(CREATED_AT) AS CUSTOMER_FIRST_ORDER_DATE,
        MAX(CREATED_AT) AS CUSTOMER_MOST_RECENT_ORDER_DATE
    FROM {{ ref('int_shopify_order') }}
    WHERE CANCELLED_AT IS NULL
    GROUP BY 1

),

email_marketing_consent as (
    SELECT
        -- Parent Customer Information
        c.ID AS CUSTOMER_ID,

        -- email marketing consent Fields
        emc.VALUE:STATE AS EMAIL_MARKETING_SKU,
        emc.VALUE:OPT_IN_LEVEL AS EMAIL_MARKETING_LEVEL,
        emc.VALUE:CONSENT_UPDATED_AT AS EMAIL_MARKETING_SUB_DATE
    FROM
        {{ source('shopify','customers') }} c,
        TABLE(FLATTEN(INPUT => c.EMAIL_MARKETING_CONSENT)) emc
)

SELECT
    distinct
    c.ID AS CUSTOMER_ID,
    c.CREATED_AT,
    c.FIRST_NAME,
    c.LAST_NAME,
    TRIM(c.FIRST_NAME)||' '||TRIM(c.LAST_NAME) AS FULL_NAME,
    TRIM(c.EMAIL) AS EMAIL,
    c.PHONE,
    a.ADDRESS_1,
    a.ADDRESS_2,
    a.CITY,
    a.COUNTRY,
    a.COUNTRY_CODE,
    a.PROVINCE,
    a.PROVINCE_CODE,
    a.ZIP,
    a.ZIP_CLEANED,
    a.FULL_ADDRESS,
    c.ORDERS_COUNT::int AS LIFETIME_ORDERS,
    od.CUSTOMER_FIRST_ORDER_DATE,
    od.CUSTOMER_MOST_RECENT_ORDER_DATE,
    (CASE
        WHEN sb.TAG IN ('Past Subscriber')
            THEN 1
        ELSE 0
    END)::BOOLEAN AS PAST_SUBSCRIBER_BOOL,
    (CASE
        WHEN sb.TAG IN ('Active Subscriber')
            THEN 1
        ELSE 0
    END)::BOOLEAN AS ACTIVE_SUBSCRIBER_BOOL,
    c.TOTAL_SPENT::FLOAT AS TOTAL_SPENT,

    emc.EMAIL_MARKETING_SKU,
    emc.EMAIL_MARKETING_LEVEL,
    emc.EMAIL_MARKETING_SUB_DATE

FROM {{ source('shopify','customers')}} c
LEFT JOIN ADDRESS a
    ON a.customer_id = c.ID
LEFT JOIN SUB sb
    ON sb.customer_id = c.ID
LEFT JOIN ORDER_DATES od
    ON od.customer_id = c.ID
left join email_marketing_consent emc
    on emc.customeR_id = c.ID
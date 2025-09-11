SELECT
    -- Parent Customer Information
    c.ID AS CUSTOMER_ID,
    CREATED_AT,
    -- Address Fields
    addr->>'ID' AS ADDRESS_ID,
    addr->>'ADDRESS1' AS ADDRESS_1,
    addr->>'ADDRESS2' AS ADDRESS_2,
    addr->>'CITY' AS CITY,
    addr->>'COMPANY' AS COMPANY,
    addr->>'COUNTRY' AS COUNTRY,
    addr->>'COUNTRY_CODE' AS COUNTRY_CODE,
    addr->>'COUNTRY_NAME' AS COUNTRY_NAME,
    addr->>'CUSTOMER_ID' AS CUSTOMER_REF_ID,
    addr->>'DEFAULT' AS IS_DEFAULT,
    addr->>'FIRST_NAME' AS FIRST_NAME,
    addr->>'LAST_NAME' AS LAST_NAME,
    addr->>'NAME' AS FULL_NAME,
    addr->>'PHONE' AS PHONE,
    addr->>'PROVINCE' AS PROVINCE,
    addr->>'PROVINCE_CODE' AS PROVINCE_CODE,
    addr->>'ZIP' AS ZIP
FROM
    {{ source('shopify','customers') }} c,
    UNNEST(c.ADDRESSES) AS addr -- Flatten the addresses array
    
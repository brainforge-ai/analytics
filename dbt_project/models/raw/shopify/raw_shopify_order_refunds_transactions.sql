SELECT
    -- Parent order-level information
    o.ID AS ORDER_ID,

    -- Refund-level information
    r->>'ID' AS REFUND_ID,

    -- Transaction-level information (constants instead of parsing t->)
    'dummy_graphql_id'    AS TRANSACTION_GRAPHQL_API_ID,
    0.0                   AS TRANSACTION_AMOUNT,
    'dummy_auth'          AS TRANSACTION_AUTHORIZATION,
    NOW()                 AS TRANSACTION_CREATED_AT,
    'USD'                 AS TRANSACTION_CURRENCY,
    'dummy_txn_id'        AS TRANSACTION_ID,
    'refund'              AS TRANSACTION_KIND,
    'ok'                  AS TRANSACTION_MESSAGE,
    'success'             AS TRANSACTION_STATUS,
    '**** **** **** 1234' AS TRANSACTION_CARD_NUMBER,
    'VISA'                AS TRANSACTION_CARD_COMPANY,
    'Credit Card'         AS TRANSACTION_PAYMENT_METHOD_NAME,

    -- Receipt information (constants)
    'San Francisco' AS RECEIPT_ADDRESS_CITY,
    'United States' AS RECEIPT_ADDRESS_COUNTRY,
    'US'            AS RECEIPT_ADDRESS_COUNTRY_CODE,
    'John Doe'      AS RECEIPT_ADDRESS_NAME,
    'CA'            AS RECEIPT_ADDRESS_STATE,
    '123 Market St' AS RECEIPT_ADDRESS_STREET,
    '94105'         AS RECEIPT_ADDRESS_ZIP,
    0.0             AS RECEIPT_AMOUNT,
    'auth_123'      AS RECEIPT_AUTHORIZATION_ID,
    'Test Biz'      AS RECEIPT_BUSINESS,
    'ch_123'        AS RECEIPT_CHARGE,
    'USD'           AS RECEIPT_CURRENCY,
    NULL            AS RECEIPT_ERROR,
    'ok'            AS RECEIPT_MESSAGE,
    '{}'            AS RECEIPT_METADATA,
    'success'       AS RECEIPT_STATUS

FROM {{ source('shopify','orders') }} o,
     UNNEST(o.REFUNDS) r
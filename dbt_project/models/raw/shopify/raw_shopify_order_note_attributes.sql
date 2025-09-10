SELECT
    -- Parent order-level information
    o.ID AS ORDER_ID, -- Order ID from the orders table

    -- Note Attributes Information
    na.VALUE:NAME::STRING AS ATTRIBUTE_NAME,
    na.VALUE:VALUE::STRING AS ATTRIBUTE_VALUE -- Convert all values to STRING for consistency
FROM
    {{ source('portable_shopify','orders') }} o,
    TABLE(FLATTEN(INPUT => o.NOTE_ATTRIBUTES)) na -- Flatten the note_attributes array

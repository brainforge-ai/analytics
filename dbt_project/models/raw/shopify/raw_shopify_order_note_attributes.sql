SELECT
    -- Parent order-level information
    o.ID AS ORDER_ID, -- Order ID from the orders table

    -- Note Attributes Information
    na->>'NAME' AS ATTRIBUTE_NAME,
    na->>'VALUE' AS ATTRIBUTE_VALUE -- Convert all values to STRING for consistency
FROM
    {{ source('shopify','orders') }} o,
    UNNEST(o.NOTE_ATTRIBUTES) na -- Flatten the note_attributes array

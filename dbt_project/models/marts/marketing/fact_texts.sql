select 
    date(timestamps) as date,
    message_id,
    message_text,
    message_type,
    subscriber_email,
    f.value::string as customer_id
from {{ source('FIVETRAN_ATTENTIVE', 'sms_sent') }},
LATERAL FLATTEN (input => custom_shopify_id, OUTER => TRUE) f

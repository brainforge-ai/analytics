with msg_data as (
    select * from {{ ref('fact_texts') }} 
), filtered_msg_data as (
select * from msg_data where customer_id is null
), 
msg_data_joined_dim_customers as (
    select 
        m.date, 
        m.message_id,
        m.message_text,
        m.message_type,
        m.subscriber_email,
        c.customer_id
    from filtered_msg_data m left join {{ ref('dim_customers') }} c
    on lower(m.subscriber_email) = lower(c.email)
),
combined_msg_data as (
    select 
        date as sms_sent_date,
        message_id,
        message_text,
        message_type,
        subscriber_email,
        customer_id
    from msg_data
    where customer_id is not null
    
    union all 

    select 
        date as sms_sent_date,
        message_id,
        message_text,
        message_type,
        subscriber_email,
        customer_id
    from msg_data_joined_dim_customers
    where customer_id is not null
),
final as (
select 
    m.*,
    cast(m.message_id as varchar) as message_id_var,
    date(o.created_at) as order_date,
    o.order_id,
    o.total_price,
    o.total_line_items_price,
    o.total_discounts,
    o.shipping_price_final
from combined_msg_data m
left join {{ ref('fact_orders')}} o
on m.customer_id = o.customer_id
and datediff(day, m.sms_sent_date, date(o.created_at)) between 0 and 5
)
select * 
from final

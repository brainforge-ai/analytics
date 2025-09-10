
with refunds as (
    select 
        order_id,
        refund_note,
        refund_id,
        max(refund_created_at) as refund_created_at,
        max(refund_processed_at) as refund_processed_at
    from {{ ref('raw_shopify_order_refunds') }}
    group by all
),

refund_transactions as (
    select 
        refund_id,
        sum(transaction_amount) as refund_amount
    from {{ ref('raw_shopify_order_refunds_transactions') }}
    where refund_id is not null
        -- and authorization is not null
        and lower(transaction_message) = 'success'
    group by all
),

refund_reasons as (
    select
        order_id,
        listagg(distinct order_adjustment_kind, ', ') as refund_code,
        listagg(distinct order_adjustment_reason,',') as refund_reason
    from {{ ref('raw_shopify_order_refunds_order_adjustments') }}
    where refund_id is not null    
    group by all
),

final as (
    select
        r.order_id,
        r.refund_note,
        rr.refund_code,
        rr.refund_reason,
        case when contains(lower(r.refund_note),'return') then 1 else 0 end::boolean as is_returned,
        t.refund_amount,
        r.refund_created_at,
        r.refund_processed_at        
    from refunds r
    left join refund_transactions t
        on t.refund_id = r.refund_id
    left join refund_reasons rr
        on rr.order_id = r.order_id    
    group by all
    having refund_amount is not null
)

select
    order_id,
    -- Aggregate refund_note data to keep one row per order, as detailed granularity isn't needed.
    LISTAGG(refund_note, ', ') as refund_note,
    LISTAGG(refund_code, ', ') as refund_code,
    LISTAGG(refund_reason, ', ') as refund_reason,
    MAX(is_returned) as is_returned,
    SUM(refund_amount) as refund_amount,
    MAX(refund_created_at) as refund_created_at,
    MAX(refund_processed_at) as refund_processed_at
from final 
GROUP BY order_id

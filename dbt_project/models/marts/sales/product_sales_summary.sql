--Marketing spend is included for funnel types protein and concentrate only. Campaigns related to Instant Latte and marketplaces have been filtered out for now to keep the spend focused on core product categories.
with spend_data as (
    select date, funnel_type, sum(spend) as total_spend
    from {{ ref('fact_campaign_spend') }}
    where funnel_type in ('protein', 'concentrate')
    group by 1, 2  
),
sales_data_raw as (
    select 
        date(created_at) as date,
        funnel_type,
        order_id,
        customer_id,
        customer_type,
        COALESCE(is_subscription_order, False) as is_subscription_order,
        is_first_subscription_order
    from {{ ref('fact_orders') }}
    where funnel_type in ('protein', 'concentrate', 'both')
    --Sales data includes orders with funnel types protein, concentrate, and both. However, approximately 2,500 orders in March 2025 are either uncategorized or assigned to other funnel types and are not included in this summary.
),
expanded_sales_data as (
--Orders marked with funnel_type = 'both' are duplicated across both 'protein' and 'concentrate' categories during the join process. This allows spend attribution to both funnels but also increases total counts (e.g., orders and new customers) due to duplication. Metrics should be interpreted with this context in mind.
    select * from sales_data_raw where funnel_type in ('protein', 'concentrate')
    union all
    select 
        date,
        'protein' as funnel_type,
        order_id,
        customer_id,
        customer_type,
        is_subscription_order,
        is_first_subscription_order
    from sales_data_raw
    where funnel_type = 'both'
    union all
    select 
        date,
        'concentrate' as funnel_type,
        order_id,
        customer_id,
        customer_type,
        is_subscription_order,
        is_first_subscription_order
    from sales_data_raw
    where funnel_type = 'both'
),
daily_aggregated_metrics as (
    select 
        date,
        funnel_type,
        count(distinct order_id) as order_count,
        count(distinct customer_id) as customer_count,
        count(distinct case when is_first_subscription_order = True then customer_id end) as new_subscriber_count,
        count(distinct case when customer_type='New' and is_subscription_order = False then customer_id end) as new_non_subscription_customer_count,   
        count(distinct case when customer_type='New' then customer_id end) as new_customer_count,   
        count(distinct case when is_first_subscription_order = True then order_id end) as new_subscription_order_count,
        count(distinct case when customer_type='New' and is_subscription_order = False then order_id end) as new_non_subscription_order_count,   
        count(distinct case when customer_type='New' then order_id end) as new_order_count   
    from expanded_sales_data
    group by 1, 2
),
final_join as (
    select 
        coalesce(m.date, s.date) as date,
        coalesce(m.funnel_type, s.funnel_type) as funnel_type,
        ifnull(s.total_spend, 0) as total_spend,
        ifnull(m.order_count, 0) as order_count,
        ifnull(m.customer_count, 0) as customer_count,
        ifnull(m.new_subscriber_count, 0) as new_subscriber_count,
        ifnull(m.new_non_subscription_customer_count, 0) as new_non_subscription_customer_count,
        ifnull(m.new_customer_count, 0) as new_customer_count,
        ifnull(m.new_subscription_order_count, 0) as new_subscription_order_count,
        ifnull(m.new_non_subscription_order_count, 0) as new_non_subscription_order_count,
        ifnull(m.new_order_count, 0) as new_order_count
    from daily_aggregated_metrics m
    full outer join spend_data s
        on m.date = s.date and m.funnel_type = s.funnel_type
)
select * from final_join

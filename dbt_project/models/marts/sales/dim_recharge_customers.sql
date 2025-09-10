with customers as (
    select *
    from {{ ref('int_recharge__customers') }}
),

final as (
    select
        customer_id,
        email,
        first_name,
        last_name,
        address_1,
        address_2,
        city,
        province,
        country_code,
        zip,
        created_at as customer_created_at,
        updated_at as customer_updated_at
    from customers
)

select * from final 
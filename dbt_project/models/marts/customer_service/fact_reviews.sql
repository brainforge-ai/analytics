select
    r.review_id,
    r.date_created,
    r.product_id,
    r.product_name,
    {{ get_product_category('r.product_name', 'r.product_name') }} as product_category,
    r.reviewer_email,
    r.reviewer_name,
    r.reviewer_is_verified,
    r.customer_id,
    r.order_id::varchar as order_id,
    r.order_number,
    r.sentiment,
    o.is_subscription_order,
    o.total_price,
    o.customer_type,
    r.rating,
    r.helpful_count,
    r.unhelpful_count,
    r.is_recommended,
    r.reward_description,
    r.reward_coupon_value,
    r.reward_coupon_value_type,
    r.reward_type,
    r.reward_value,
    r.contains_profanity,
    r.status,
    r.review_source,

    -- Attributes from int_review_attributes
    ira.shipping_speed_rating,
    ira.shipping_rating,
    ira.caffeine_amount_rating,
    ira.convenience_rating,
    ira.taste_rating,
    ira.value_for_money_rating,
    ira.flavor_profile_rating,
    ira.easy_to_use_rating,

    ira.use_dummyclient_everyday,
    ira.product_taste_feedback,
    ira.dummyclient_usage_frequency,
    ira.shipping_feedback,

    -- Media counts from int_review_media_summary
    im.number_of_images,
    im.number_of_videos,
    im.number_of_audio_files,
    im.total_media_count,

    -- calculated fields

    case when im.total_media_count > 0 then True else False end as has_media,
    case when lower(r.product_name) = 'dummyclient' then True else False end as is_site_review

from {{ ref('int_reviews') }} r
left join {{ ref('int_review_attributes') }} ira on r.review_id::varchar = ira.review_id::varchar
left join {{ ref('int_review_media_summary') }} im on r.review_id::varchar = im.review_id::varchar
left join {{ ref('fact_orders') }} o on r.order_id::varchar = o.order_id::varchar

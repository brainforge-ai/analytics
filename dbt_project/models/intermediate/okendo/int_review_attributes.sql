

select
    coalesce(rar.review_id, rpp.review_id) as review_id,

    -- Ratings from attribute_with_rating
    rar.shipping_speed_rating,
    rar.shipping_rating,
    rar.caffeine_amount_rating,
    rar.convenience_rating,
    rar.taste_rating,
    rar.value_for_money_rating,
    rar.flavor_profile_rating,
    rar.easy_to_use_rating,

    -- Product attributes
    rpp.use_dummyclient_everyday,
    rpp.product_taste_feedback,
    rpp.dummyclient_usage_frequency,
    rpp.shipping_feedback

from
    {{ ref('int_review_attribute_with_rating_pivoted') }} rar
full outer join
    {{ ref('int_review_product_attribute_parsed') }} rpp
on rar.review_id = rpp.review_id

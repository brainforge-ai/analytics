select 
    date(date) as date,
    md5(breakdown_cmpgn_product_filter) as campaign_id,
    md5(breakdown_platform_northbeam) as platform_id,
    case
        when lower(breakdown_cmpgn_product_filter) like '%protein%' then 'protein'
        when lower(breakdown_cmpgn_product_filter) like '%concentrate%' then 'concentrate'
        else lower(breakdown_cmpgn_product_filter)
    end as funnel_type,
    ifnull(spend, 0) as spend
from {{ source('PORTABLE_NORTHBEAM', 'data_export_results') }} 

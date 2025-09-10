select 
    breakdown_cmpgn_product_filter as campaign_name,
    md5(breakdown_cmpgn_product_filter) as campaign_id,
from {{ source('PORTABLE_NORTHBEAM', 'data_export_results') }} 

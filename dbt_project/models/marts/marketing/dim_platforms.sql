select 
    breakdown_platform_northbeam as platform_name,
    md5(breakdown_platform_northbeam) as platform_id,
from {{ source('PORTABLE_NORTHBEAM', 'data_export_results') }} 

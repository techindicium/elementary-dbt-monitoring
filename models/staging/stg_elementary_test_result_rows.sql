with
    renamed as (
        select
            elementary_test_results_id
            , result_row as test_result_row
            , {{ dbt.dateadd('hour', -3, 'detected_at') }} as test_detected_at
        from {{ source('raw_dbt_monitoring', 'test_result_rows') }}
    )

select *
from renamed

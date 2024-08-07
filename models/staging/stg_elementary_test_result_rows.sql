with
    renamed as (
        select
            elementary_test_results_id
            , result_row as test_result_row
            , detected_at as test_detected_at
            , cast(detected_at as date) as test_detected_date
        from {{ source('raw_dbt_monitoring', 'test_result_rows') }}
    )

select *
from renamed

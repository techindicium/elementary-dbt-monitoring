with
    renamed as (
        select
            source_freshness_execution_id
            , unique_id as source_freshness_id
            , dateadd(hours, -3, cast(max_loaded_at as timestamp)) as source_max_loaded_at
            , dateadd(hours, -3, cast(snapshotted_at as timestamp)) as source_snapshotted_at
            , dateadd(hours, -3, cast(generated_at as timestamp)) as source_freshness_generated_at
            , cast(generated_at as date) as source_generate_date
            , cast(max_loaded_at_time_ago_in_s as double precision) as source_max_loaded_at_seconds
            , status as source_status
            , upper(error) as source_error
            , dateadd(hours, -3, cast(compile_started_at as timestamp)) as source_compile_started_at
            , dateadd(hours, -3, cast(compile_completed_at as timestamp)) as source_compile_completed_at
            , dateadd(hours, -3, cast(execute_started_at as timestamp)) as source_execute_started_at
            , dateadd(hours, -3, cast(execute_completed_at as timestamp)) as source_execute_completed_at
            , invocation_id
        from {{ source('raw_dbt_monitoring', 'dbt_source_freshness_results') }}
    )
select *
from renamed
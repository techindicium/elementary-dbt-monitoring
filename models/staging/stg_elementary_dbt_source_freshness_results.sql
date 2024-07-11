with
    renamed as (
        select
            source_freshness_execution_id
            , unique_id as source_freshness_id
            , cast(max_loaded_at as timestamp) as max_loaded_at
            , cast(snapshotted_at as timestamp) as snapshotted_at
            , cast(generated_at as timestamp) as generated_at
            , cast(generated_at as date) as source_generate_date
            , max_loaded_at_time_ago_in_s as source_max_loaded_at_seconds
            , status as source_status
            , upper(error) as source_error
            , cast(compile_started_at as timestamp) as compile_started_at
            , cast(compile_completed_at as timestamp) as compile_completed_at
            , cast(execute_started_at as timestamp) as execute_started_at
            , cast(execute_completed_at as timestamp) as execute_completed_at
            , invocation_id
        from {{ source('raw_dbt_monitoring', 'dbt_source_freshness_results') }}
    )

    , dbt_dateadd as (
        select
            source_freshness_execution_id
            , source_freshness_id
            , max_loaded_at as source_max_loaded_at
            , snapshotted_at as source_snapshotted_at
            , generated_at as source_freshness_generated_at
            , source_generate_date
            , source_max_loaded_at_seconds
            , source_status
            , source_error
            , compile_started_at as source_compile_started_at
            , compile_completed_at as source_compile_completed_at
            , execute_started_at as source_execute_started_at
            , execute_completed_at as source_execute_completed_at
            , invocation_id
        from renamed
    )

select *
from dbt_dateadd
with
    renamed as (
        select
            model_execution_id
            , unique_id as run_result_id
            , invocation_id
            , cast(generated_at as timestamp) as generated_at
            , name as run_result_name
            , message as sql_statement
            , status as invocation_status
            , resource_type
            , execution_time
            , cast(execute_started_at as timestamp) as execute_started_at
            , cast(execute_completed_at as timestamp) as execute_completed_at
            , cast(compile_started_at as timestamp) as compile_started_at
            , cast(compile_completed_at as timestamp) as compile_completed_at
            , coalesce(rows_affected, 0) as rows_affected
            , query_id
            , full_refresh as is_full_refresh
            , compiled_code
            , coalesce(cast(failures as integer), 0) as failures
            , thread_id
        from {{ source('raw_dbt_monitoring', 'dbt_run_results') }}
    )

    , dbt_dateadd as (
        select
            model_execution_id
            , run_result_id
            , invocation_id
            , {{ dbt.dateadd("hour", -3, 'generated_at') }} as invocation_generated_at
            , run_result_name
            , sql_statement
            , invocation_status
            , resource_type
            , execution_time
            , cast(generated_at as date) as run_date
            , {{ dbt.dateadd("hour", -3, 'execute_started_at') }} as run_started_at
            , {{ dbt.dateadd("hour", -3, 'execute_completed_at') }} as run_completed_at
            , {{ dbt.dateadd("hour", -3, 'compile_started_at') }} as compile_started_at
            , {{ dbt.dateadd("hour", -3, 'compile_completed_at') }} as compile_completed_at
            , rows_affected
            , query_id
            , is_full_refresh
            , compiled_code
            , failures
            , thread_id
        from renamed
    )

select *
from dbt_dateadd
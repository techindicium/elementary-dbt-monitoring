with
    renamed as (
        select
            model_execution_id
            , unique_id as run_result_id
            , invocation_id
            , dateadd(hours, -3, cast(generated_at as timestamp)) as invocation_generated_at
            , name as run_result_name
            , message as sql_statement
            , status as invocation_status
            , resource_type
            , execution_time
            , cast(generated_at as date) as run_date
            , dateadd(hours, -3, cast(execute_started_at as timestamp)) as run_started_at
            , dateadd(hours, -3, cast(execute_completed_at as timestamp)) as run_completed_at
            , dateadd(hours, -3, cast(compile_started_at as timestamp)) as compile_started_at
            , dateadd(hours, -3, cast(compile_completed_at as timestamp)) as compile_completed_at
            , coalesce (rows_affected, 0) as rows_affected
            , full_refresh as is_full_refresh
            , compiled_code
            , coalesce(cast(failures as integer), 0) as failures
            , thread_id
        from {{ source('raw_dbt_monitoring', 'dbt_run_results') }}
    )
select *
from renamed
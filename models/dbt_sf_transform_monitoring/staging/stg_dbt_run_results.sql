with
    stg_elementary_dbt_run_results as (
        select
            cast(model_execution_id as string) as model_execution_id
            , cast(unique_id as string) as unique_id
            , cast(invocation_id as string) as invocation_id
            , cast(generated_at as datetime) as generated_at
            , cast(name as string) as resource_name
            , cast(message as string) as log_message
            , cast(status as string) as run_status
            , cast(resource_type as string) resource_type
            , round(execution_time, 3) as execution_time
            , cast(execute_started_at as datetime) as execute_started_at
            , cast(execute_completed_at as datetime) as execute_completed_at
            , cast(compile_started_at as datetime) as compile_started_at
            , cast(compile_completed_at as datetime) as compile_completed_at
            , cast(rows_affected as int) as rows_affected
            , cast(full_refresh as boolean) as full_refresh
            , cast(compiled_code as string) as compiled_code
            , cast(failures as int) as failures
            , cast(query_id as string) as query_id
            , cast(thread_id as string) as thread_id
            , cast(materialization as string) as materialization
            , cast(adapter_response as string) as adapter_response
        from {{ source('raw_elementary','dbt_run_results') }}
    )

select *
from stg_elementary_dbt_run_results
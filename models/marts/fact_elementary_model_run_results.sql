with
    util_days as (
        select cast(date_day as date) as date_day 
        from {{ ref('dbt_utils_day') }}
    )
    , models as (
        select distinct
            model_sk
            , model_id
        from {{ ref('dim_elementary_models') }}
    )
    , invocations as (
        select distinct
            invocation_sk
            , invocation_id
        from {{ ref('fact_elementary_invocations') }}
    )
    , run_results as (
        select
            model_execution_id
            , run_result_id
            , invocation_id
            , invocation_generated_at
            , invocation_status
            , resource_type
            , execution_time
            , run_date
            , run_started_at
            , run_completed_at
            , compile_started_at
            , compile_completed_at
            , rows_affected
            , query_id
            , is_full_refresh
            , failures
        from {{ ref('stg_elementary_dbt_run_results') }}
    )
    , model_run_results_joined_with_sk as (
        select distinct
            {{ dbt_utils.generate_surrogate_key(['run_results.model_execution_id', 'run_results.run_result_id', 'models.model_sk']) }} as model_run_result_sk
            , run_results.model_execution_id
            , models.model_sk as model_fk
            , invocations.invocation_sk as invocation_fk
            , run_results.run_result_id
            , util_days.date_day as run_date
            , run_results.invocation_generated_at
            , run_results.invocation_status
            , run_results.resource_type
            , run_results.execution_time
            , run_results.failures
            , run_results.run_started_at
            , run_results.run_completed_at
            , run_results.compile_started_at
            , run_results.compile_completed_at
            , run_results.rows_affected
            , run_results.query_id
            , run_results.is_full_refresh
            , row_number() over (
                partition by run_results.run_result_id
                order by run_results.invocation_generated_at desc
            ) as model_invocation_reverse_index
        from run_results
        right join models on run_results.run_result_id = models.model_id
        left join util_days on run_results.run_date = util_days.date_day
        left join invocations on run_results.invocation_id = invocations.invocation_id
    )
select *
from model_run_results_joined_with_sk
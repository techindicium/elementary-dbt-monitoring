with
    util_days as (
        select cast(date_day as date) as date_day
        from {{ ref('dbt_utils_day') }}
    )
    , invocations as (
        select distinct
            invocation_sk
            , invocation_id
        from {{ ref('fact_elementary_invocations') }}
    )
    , dim_tests as (
        select distinct
            test_sk
            , test_id
        from {{ ref('dim_elementary_tests') }}
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
            , is_full_refresh
            , failures
        from {{ ref('stg_elementary_dbt_run_results') }}
    )
    , elementary_test_results as (
        select
            elementary_test_results_id
            , test_id
            , invocation_id
            , test_detected_date
            , test_type
            , test_status
            , test_failures
        from {{ ref('stg_elementary_elementary_test_results') }}
    )
    , fact_test_results as (
        select
            elementary_test_results.elementary_test_results_id
            , elementary_test_results.test_id
            , run_results.run_result_id
            , elementary_test_results.invocation_id as invocation_id
            , elementary_test_results.test_detected_date
            , elementary_test_results.test_type
            , elementary_test_results.test_status
            , elementary_test_results.test_failures
            , run_results.model_execution_id
            , run_results.invocation_generated_at
            , run_results.invocation_status
            , run_results.resource_type
            , run_results.execution_time
            , run_results.run_date
            , run_results.run_started_at
            , run_results.run_completed_at
            , run_results.compile_started_at
            , run_results.compile_completed_at
            , run_results.rows_affected
            , run_results.is_full_refresh
            , run_results.failures
        from run_results
        left join elementary_test_results
            on run_results.invocation_id = elementary_test_results.invocation_id
            and run_results.run_result_id = elementary_test_results.test_id
        where elementary_test_results.test_type is not null
    )
    , join_with_dim as (
        select
            {{ dbt_utils.generate_surrogate_key([
                'fact_test_results.model_execution_id'
                , 'fact_test_results.elementary_test_results_id'
                , 'dim_tests.test_sk'
                , 'invocations.invocation_sk'
            ]) }} as test_run_result_sk
            , fact_test_results.elementary_test_results_id
            , fact_test_results.model_execution_id
            , dim_tests.test_sk as test_fk
            , invocations.invocation_sk as invocation_fk
            , util_days.date_day as test_detected_date
            , fact_test_results.test_type
            , fact_test_results.test_status
            , fact_test_results.run_started_at
            , fact_test_results.run_completed_at
            , fact_test_results.execution_time
            , fact_test_results.test_failures
        from fact_test_results
        left join dim_tests on fact_test_results.test_id = dim_tests.test_id
        left join invocations on fact_test_results.invocation_id = invocations.invocation_id
        left join util_days on fact_test_results.test_detected_date = util_days.date_day
    )
select *
from join_with_dim
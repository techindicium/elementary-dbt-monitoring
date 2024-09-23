with
    util_days as (
        select cast(date_day as date) as date_day
        from {{ ref('dbt_elementary_utils_day') }}
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
    , tests_result_row as (
        select
            elementary_test_results_id
            , test_result_row
            , test_detected_date
            , row_number () over (
                partition by elementary_test_results_id
                order by test_detected_at
            ) as rn
        from {{ ref('stg_elementary_test_result_rows') }}
    )
    , fact_test_results as (
        select
            elementary_test_results.elementary_test_results_id
            , elementary_test_results.test_id
            , run_results.run_result_id
            , elementary_test_results.invocation_id as invocation_id
            , elementary_test_results.test_detected_date
            , elementary_test_results.test_type
            , run_results.model_execution_id
            , run_results.run_date
        from run_results
        left join elementary_test_results on run_results.run_result_id = elementary_test_results.test_id
        where test_type is not null
    )
    , join_with_dim as (
        select
            {{ dbt_utils.generate_surrogate_key([
                'fact_test_results.model_execution_id'
                , 'fact_test_results.elementary_test_results_id'
                , 'dim_tests.test_sk'
                , 'invocations.invocation_sk'
                , 'tests_result_row.test_result_row'
            ]) }} as test_run_result_row_sk
            , dim_tests.test_sk as test_fk
            , invocations.invocation_sk as invocation_fk
            , fact_test_results.elementary_test_results_id
            , fact_test_results.model_execution_id
            , util_days.date_day as test_detected_date
            , tests_result_row.test_result_row
        from fact_test_results
        left join dim_tests on fact_test_results.test_id = dim_tests.test_id
        left join invocations on fact_test_results.invocation_id = invocations.invocation_id
        left join util_days on fact_test_results.test_detected_date = util_days.date_day
        left join tests_result_row on fact_test_results.elementary_test_results_id = tests_result_row.elementary_test_results_id
        where (tests_result_row.test_result_row is not null
            and rn = 1)
    )
select *
from join_with_dim

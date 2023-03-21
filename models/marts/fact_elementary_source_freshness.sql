with
    util_days as (
        select * 
        from {{ ref('dbt_utils_day') }}
    )
    , sources as (
        select *
        from {{ ref('dim_elementary_sources') }}
    )
    , invocations as (
        select
            invocation_sk
            , invocation_id
        from {{ ref('fact_elementary_invocations') }}
    )
    , source_freshness as (
        select
            source_freshness_execution_id
            , source_freshness_id
            , invocation_id
            , source_max_loaded_at
            , source_snapshotted_at
            , source_freshness_generated_at
            , source_generate_date
            , source_max_loaded_at_seconds
            , source_status
            , source_error
            , source_compile_started_at
            , source_compile_completed_at
            , source_execute_started_at
            , source_execute_completed_at
        from {{ ref('stg_elementary_dbt_source_freshness_results') }}
    )
    , source_freshness_joined_with_sk as (
        select
            {{ dbt_utils.surrogate_key(['source_freshness.source_freshness_execution_id']) }} as source_freshness_sk
            , sources.source_sk as source_fk
            , invocations.invocation_sk as invocation_fk
            , util_days.date_day as source_generate_date
            , source_freshness.source_snapshotted_at
            , source_freshness.source_freshness_generated_at
            , source_freshness.source_max_loaded_at_seconds
            , source_freshness.source_status
            , source_freshness.source_error
            , source_freshness.source_compile_started_at
            , source_freshness.source_compile_completed_at
            , source_freshness.source_execute_started_at
            , source_freshness.source_execute_completed_at
        from source_freshness
        left join sources on source_freshness.source_freshness_id = sources.source_id
        left join invocations on source_freshness.invocation_id = invocations.invocation_id
        left join util_days on source_freshness.source_generate_date = util_days.date_day
    )
select *
from source_freshness_joined_with_sk
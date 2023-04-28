with
    util_days as (
        select cast(date_day as date) as date_day
        from {{ ref('dbt_utils_day') }}
    )
    , stg_invocations as (
        select distinct
            invocation_id
            , job_id
            , job_name
            , job_run_id
            , invocation_started_at
            , invocation_completed_at
            , invocation_date
            , dbt_invocation_command
            , is_full_refresh
            , invocation_vars
            , vars
            , target_name
            , target_database
            , target_schema
            , target_profile_name
            , threads
            , models_ran
            , project_id
            , project_name
        from {{ ref('stg_elementary_dbt_invocations') }}
    )
    , joined_with_sk as (
        select distinct
            {{ dbt_utils.surrogate_key(['invocation_id']) }} as invocation_sk
            , invocation_id
            , job_id
            , job_name
            , job_run_id
            , invocation_started_at
            , invocation_completed_at
            , util_days.date_day as invocation_date
            , dbt_invocation_command
            , is_full_refresh
            , invocation_vars
            , vars
            , target_name
            , target_database
            , target_schema
            , target_profile_name
            , threads
            , models_ran
            , project_id
            , project_name
        from stg_invocations
        left join util_days on stg_invocations.invocation_date = util_days.date_day
    )
select *
from joined_with_sk
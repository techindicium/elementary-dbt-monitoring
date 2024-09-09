with
    run_results as (
        /* Extract run results from the staging table */
        select *
        from {{ ref('stg_dbt_run_results') }}
    )

    , invocation_details as (
        /* Extract invocations data from the staging table */
        select *
        from {{ ref('stg_dbt_invocations') }}
    )

    , enriched_execution_data as (
        /* Join run results with invocations to enrich run data with invocation-related information */
        select 
            run_results.*
            , invocations.job_id
            , invocations.job_name
            , invocations.job_run_id
            , invocations.run_started_at
            , invocations.run_completed_at
            , invocations.created_at
            , invocations.command
            , invocations.dbt_version
            , invocations.elementary_version
            , invocations.invocation_vars
            , invocations.vars
            , invocations.target_name
            , invocations.target_database
            , invocations.target_schema
            , invocations.target_profile_name
            , invocations.threads
            , invocations.selected
            , invocations.yaml_selector
            , invocations.project_id
            , invocations.project_name
            , invocations.env
            , invocations.env_id
            , invocations.cause_category
            , invocations.cause
            , invocations.pull_request_id
            , invocations.git_sha
            , invocations.orchestrator
            , invocations.dbt_user
            , invocations.job_url
            , invocations.job_run_url
            , invocations.account_id
        from run_results
        left join invocation_details as invocations 
            on run_results.invocation_id = invocations.invocation_id
    )

    , execution_analysis as (
        /* Calculate execution times and derive last execution and last success flags */
        select
            exc.*
            , round((exc.execution_time/60), 3) as execution_time_min
            , coalesce(exc.execute_started_at, exc.run_started_at) as consolidated_started_at
            , row_number() over (
                partition by exc.resource_name
                order by coalesce(
                    exc.execute_started_at
                    , exc.run_started_at
                ) desc
            ) as last_execution_index
            , row_number() over (
                partition by exc.resource_name, exc.run_status
                order by coalesce(
                    exc.execute_started_at
                    , exc.run_started_at
                ) desc
            ) as last_execution_success_index
        from enriched_execution_data as exc
    )

    , execution_flags as (
        /* Add additional flags and extract relevant date truncations for the analysis */
        select
            *
            , date_trunc('day', generated_at) as generated_at_date
            , case
                when last_execution_index = 1
                    then true
                else
                    false
            end as last_execution
            , case
                when last_execution_index = 1 and consolidated_started_at >= dateadd(day, -7, current_timestamp())
                    then true
                when last_execution_index != 1
                    then null
                else
                    false
            end as execution_last_seven_days
            , case
                when last_execution_success_index = 1 and run_status = 'success'
                    then true
                else
                    false
            end as last_success_execution
        from execution_analysis
    )

select *
from execution_flags

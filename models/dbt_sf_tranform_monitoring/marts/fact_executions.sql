with
    run_results as (
        select *
        from {{ ref('stg_dbt_run_results') }}
    )

    , invocations as (
        select *
        from {{ ref('stg_dbt_invocations') }}
    )

    , join_execution_models as (
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
        left join invocations 
            on run_results.invocation_id = invocations.invocation_id
    )

    , aux_new_rules as (
        select
            exc.*
            , round((exc.execution_time/60), 3) as execution_time_min
            , coalesce(exc.execute_started_at, exc.run_started_at) as consolidated_stated_at /*dm_inicio_execucao*/
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
        from join_execution_models as exc
    )

    , new_rules as (
        select
            *
            -- , coalesce(
            --     regexp_substr(adapter_response, '\\d+\\.\\d+\\sKiB'),
            --     regexp_substr(adapter_response, '\\d+\\.\\d+\\sKB'),
            --     regexp_substr(adapter_response, '\\d+\\.\\d+\\sMiB'),
            --     regexp_substr(adapter_response, '\\d+\\.\\d+\\sMB'),
            --     regexp_substr(adapter_response, '\\d+\\.\\d+\\sGiB'),
            --     regexp_substr(adapter_response, '\\d+\\.\\d+\\sGB'),
            --     '0.0'
            -- ) as bytes_processed
            , date_trunc('day', generated_at) as generated_at_date
            , case
                when last_execution_index = 1
                    then true
                else
                    false
            end as last_execution
            , case
                when last_execution_index = 1 and consolidated_stated_at >= dateadd(day, -7, current_timestamp())
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
        from aux_new_rules
    )

select *
from new_rules

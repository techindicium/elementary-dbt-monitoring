with
    stg_elementary_dbt_invocations as (
        select
            cast(invocation_id as string) as invocation_id
            , cast(job_id as string) as job_id
            , cast(job_name as string) as job_name
            , cast(job_run_id as string) as job_run_id
            , cast(run_started_at as datetime) as run_started_at
            , cast(run_completed_at as datetime) as run_completed_at
            , cast(generated_at as datetime) as generated_at
            , cast(created_at as datetime) as created_at
            , cast(command as string) as command
            , cast(dbt_version as string) as dbt_version
            , cast(elementary_version as string) as elementary_version
            , cast(full_refresh as boolean) as full_refresh
            , cast(invocation_vars as string) as invocation_vars
            , cast(vars as string) as vars
            , cast(target_name as string) as target_name
            , cast(target_database as string) as target_database
            , cast(target_schema as string) as target_schema
            , cast(target_profile_name as string) as target_profile_name
            , cast(threads as string) as threads
            , cast(selected as string) as selected
            , cast(yaml_selector as string) as yaml_selector
            , cast(project_id as string) as project_id
            , cast(project_name as string) as project_name
            , cast(env as string) as env
            , cast(env_id as string) as env_id
            , cast(cause_category as string) as cause_category
            , cast(cause as string) as cause
            , cast(pull_request_id as string) as pull_request_id
            , cast(git_sha as string) as git_sha
            , cast(orchestrator as string) as orchestrator
            , cast(dbt_user as string) as dbt_user
            , cast(job_url as string) as job_url
            , cast(job_run_url as string) as job_run_url
            , cast(account_id as string) as account_id
        from {{ source('raw_elementary','dbt_invocations') }}
    )

select *
from stg_elementary_dbt_invocations

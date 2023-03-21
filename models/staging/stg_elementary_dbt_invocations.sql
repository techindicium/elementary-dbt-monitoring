with
    renamed as (
        select distinct
            invocation_id
            , job_id
            , job_name
            , job_run_id
            , dateadd(hours, -3, cast(run_started_at as timestamp)) as invocation_started_at
            , dateadd(hours, -3, cast(run_completed_at as timestamp)) as invocation_completed_at
            , dateadd(hours, -3, cast(invocation_started_at as date)) as invocation_date
            , dateadd(hours, -3, cast(generated_at as timestamp)) as invocation_generated_at
            , case
                when command = 'test' then 'dbt test'
                when command = 'run' then 'dbt run'
                when command = 'build' then 'dbt build'
            end as dbt_invocation_command
            , dbt_version
            , elementary_version
            , full_refresh as is_full_refresh
            , invocation_vars
            , vars
            , target_name
            , target_database
            , target_schema
            , target_profile_name
            , threads
            , selected as models_ran
            , yaml_selector
            , project_id
            , project_name
        from {{ source('raw_dbt_monitoring', 'dbt_invocations') }}
    )
select *
from renamed
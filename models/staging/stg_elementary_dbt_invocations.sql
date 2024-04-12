with
    renamed as (
        select distinct
            invocation_id
            , job_id
            , job_name
            , job_run_id
            , cast(run_started_at as timestamp) as run_started_at
            , cast(run_completed_at as timestamp) as run_completed_at
            , cast(generated_at as timestamp) as generated_at
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

    , dbt_dateadd as (
        select distinct
            invocation_id
            , job_id
            , job_name
            , job_run_id
            , {{ dbt.dateadd("hour", -3, 'run_started_at') }} as invocation_started_at
            , {{ dbt.dateadd('hour', -3, 'run_completed_at') }} as invocation_completed_at
            , {{ dbt.dateadd('hour', -3, 'run_started_at') }} as invocation_date
            , {{ dbt.dateadd('hour', -3, 'generated_at') }} as invocation_generated_at
            , dbt_invocation_command
            , dbt_version
            , elementary_version
            , is_full_refresh
            , invocation_vars
            , vars
            , target_name
            , target_database
            , target_schema
            , target_profile_name
            , threads
            , models_ran
            , yaml_selector
            , project_id
            , project_name
        from renamed
    )

select *
from dbt_dateadd
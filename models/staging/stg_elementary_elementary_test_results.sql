with
    renamed as (
        select
            id as elementary_test_results_id
            , cast(data_issue_id as date) as data_issue_id
            , test_execution_id
            , test_unique_id as test_id
            , model_unique_id as model_id
            , invocation_id
            , {{ dbt.dateadd("hour", -3, 'detected_at') }} as test_detected_at
            , database_name as project_database_name
            , schema_name
            , table_name
            , column_name
            , test_type
            , test_sub_type
            , test_results_description
            , tags as invocation_tags
            , test_results_query
            , test_name
            , test_params as test_parameters
            , upper(severity) as severity
            , status as test_status
            , cast(failures as integer) as test_failures
            , test_short_name
            , test_alias
            , result_rows
        from {{ source('raw_dbt_monitoring', 'elementary_test_results') }}
    )

select *
from renamed
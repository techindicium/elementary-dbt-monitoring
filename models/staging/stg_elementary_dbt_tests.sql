with
    source as (
        select distinct
            unique_id as test_id
            , database_name as project_database_name
            , schema_name
            , name as test_name
            , type as test_type
            , short_name as test_short_name
            , case
                when test_type = 'singular' then 'singular'
                when test_type = 'generic' and test_short_name = 'not_null' then 'not_null'
                when test_type = 'generic' and test_short_name = 'unique' then 'unique'
                when test_type = 'generic' and test_short_name = 'relationships' then 'relationships'
                when test_type = 'generic' and test_short_name = 'accepted_values' then 'accepted_values'
                else 'other'
            end as test_type_mod
            , alias
            , test_column_name
            , upper(severity) as test_severity
            , warn_if as test_warn_if
            , error_if as test_error_if
            , test_params as test_parameters
            , tags as test_tags
            , model_tags
            , meta as test_metadata
            , depends_on_macros as test_depends_on_macros
            , depends_on_nodes as test_depends_on_nodes
            , parent_model_unique_id
            , description as test_description
            , package_name
            , original_path
            , path as dbt_test_path
            , cast(generated_at as timestamp) as test_generated_at
            , metadata_hash
        from {{ source('raw_dbt_monitoring', 'dbt_tests') }}
    )
select *
from source
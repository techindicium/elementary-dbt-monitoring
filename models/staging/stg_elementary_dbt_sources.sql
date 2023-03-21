with
    renamed as (
        select distinct
            unique_id as source_id
            , database_name as project_database_name
            , schema_name
            , source_name
            , name as table_name
            , loaded_at_field
            , freshness_warn_after
            , freshness_error_after
            , relation_name
            , tags as source_tags
            , package_name
            , path as dbt_source_path
            , source_description
            , description as source_table_description
            , dateadd(hours, -3, cast(generated_at as timestamp)) as source_generated_at
            , metadata_hash
        from {{ source('raw_dbt_monitoring', 'dbt_sources') }}
    )
select *
from renamed
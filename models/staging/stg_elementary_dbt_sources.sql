with
    renamed as (
        select
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
            , cast(generated_at as timestamp) generated_at
            , metadata_hash
        from {{ source('raw_dbt_monitoring', 'dbt_sources') }}
        qualify row_number() over(
            partition by source_id
            order by generated_at desc
        ) = 1
    )

    , dbt_dateadd as (
        select
            source_id
            , project_database_name
            , schema_name
            , source_name
            , table_name
            , loaded_at_field
            , freshness_warn_after
            , freshness_error_after
            , relation_name
            , source_tags
            , package_name
            , dbt_source_path
            , source_description
            , source_table_description
            , generated_at as source_generated_at
            , metadata_hash
        from renamed
    )

select *
from dbt_dateadd
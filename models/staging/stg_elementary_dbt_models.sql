with
    renamed as (
        select distinct
            unique_id as model_id
            , checksum
            , materialization
            , tags as model_tags
            , database_name as project_database_name
            , schema_name
            , depends_on_macros as model_depends_on_macros
            , depends_on_nodes as model_depends_on_nodes
            , description as model_description
            , path as dbt_model_path
            , name as model_name
            , case
                when name like '%fact_%' then 'Fact'
                when name like '%dim_%' then 'Dim'
                when name like '%stg_%' then 'Stg'
                when name like '%agg_%' then 'Agg'
                when name like '%bridge_%' then 'Bridge'
                when path like '%edr/%' then 'Elementary'
                else 'Other'
            end as table_type_mod
            , package_name
            , original_path
            , cast(generated_at as timestamp) as generated_at
            , metadata_hash
        from {{ source('raw_dbt_monitoring', 'dbt_models') }}
    )

    , dbt_dateadd as (
        select distinct
            model_id
            , checksum
            , materialization
            , model_tags
            , project_database_name
            , schema_name
            , model_depends_on_macros
            , model_depends_on_nodes
            , model_description
            , dbt_model_path
            , model_name
            , table_type_mod
            , package_name
            , original_path
            , generated_at as model_generated_at
            , metadata_hash
        from renamed
    )

select *
from dbt_dateadd
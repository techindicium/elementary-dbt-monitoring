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
                when model_name like '%fact_%' then 'Fact'
                when model_name like '%dim_%' then 'Dim'
                when model_name like '%stg_%' then 'Stg'
                when model_name like '%agg_%' then 'Agg'
                when model_name like '%bridge_%' then 'Bridge'
                when dbt_model_path like '%edr/%' then 'Elementary'
                else 'Other'
            end as table_type_mod
            , package_name
            , original_path
            , dateadd(hours, -3, cast(generated_at as timestamp)) as model_generated_at
            , metadata_hash
        from {{ source('raw_dbt_monitoring', 'dbt_models') }}
    )
select *
from renamed
with
    stg_sources as (
        select distinct
            source_id
            , source_name
            , table_name
            , project_database_name
            , schema_name
            , relation_name
            , source_tags
            , package_name
            , dbt_source_path
            , source_description
            , source_table_description
            , source_generated_at
        from {{ ref('stg_elementary_dbt_sources') }}
    )
    , stg_sources_with_sk as (
        select
            {{ dbt_utils.generate_surrogate_key(['source_id']) }} as source_sk
            , *
        from stg_sources
    )
select *
from stg_sources_with_sk
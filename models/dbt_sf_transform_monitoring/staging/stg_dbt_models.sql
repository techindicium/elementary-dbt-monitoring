with
    dbt_models as (
        select
            cast(unique_id as string) as unique_id
            , cast(alias as string) as model_alias
            , cast(checksum as string) as checksum
            , cast(materialization as string) as materialization
            , cast(tags as string) as model_tags
            , cast(meta as string) as model_meta
            , cast(owner as string) as model_owner
            , cast(database_name as string) as database_name
            , cast(schema_name as string) as schema_name
            , cast(depends_on_macros as string) as depends_on_macros
            , cast(depends_on_nodes as string) as depends_on_nodes
            , cast(description as string) as model_description
            , cast(name as string) as model_name
            , cast(package_name as string) as package_name
            , cast(original_path as string) as original_path
            , cast(path as string) as model_path
            , cast(generated_at as datetime) as generated_at
            , cast(metadata_hash as string) as metadata_hash
        from {{ source('raw_elementary','dbt_models') }}
    )

select *
from dbt_models
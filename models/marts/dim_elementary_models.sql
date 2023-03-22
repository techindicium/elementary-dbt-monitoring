with
    stg_models as (
        select distinct
            model_id
            , materialization
            , model_tags
            , project_database_name
            , schema_name
            , model_depends_on_nodes
            , model_description
            , model_name
            , table_type_mod
            , dbt_model_path
            , model_generated_at
        from {{ ref('stg_elementary_dbt_models') }}
    )
    , stg_models_with_sk as (
        select distinct
            {{ dbt_utils.surrogate_key(['model_id']) }} as model_sk
            , *
        from stg_models
    )
select *
from stg_models_with_sk
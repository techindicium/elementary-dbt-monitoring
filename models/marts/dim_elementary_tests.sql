with
    stg_tests as (
        select distinct
            test_id
            , project_database_name
            , schema_name
            , test_name
            , test_short_name
            , test_type_mod
            , test_column_name
            , test_severity
            , test_tags
            , test_depends_on_macros
            , test_depends_on_nodes
            , parent_model_unique_id
            , test_description
            , package_name
            , test_type
            , dbt_test_path
            , test_generated_at
        from {{ ref('stg_elementary_dbt_tests') }}
    )
    , stg_tests_with_sk as (
        select distinct
            {{ dbt_utils.surrogate_key(['test_id']) }} as test_sk
            , *
        from stg_tests
    )
select *
from stg_tests_with_sk
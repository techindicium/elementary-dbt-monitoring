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
    , stg_models as (
        select distinct
            model_id
            , model_name
        from {{ ref('stg_elementary_dbt_models') }}
    )
    , joined_tests_models as (
        select
            stg_tests.test_id
            , stg_tests.project_database_name
            , stg_tests.schema_name
            , stg_models.model_name
            , stg_tests.test_name
            , stg_tests.test_short_name
            , stg_tests.test_type_mod
            , stg_tests.test_column_name
            , stg_tests.test_severity
            , stg_tests.test_tags
            , stg_tests.test_depends_on_macros
            , stg_tests.test_depends_on_nodes
            , stg_tests.parent_model_unique_id
            , stg_tests.test_description
            , stg_tests.package_name
            , stg_tests.test_type
            , stg_tests.dbt_test_path
            , stg_tests.test_generated_at
        from stg_tests
        left join stg_models on stg_tests.parent_model_unique_id = stg_models.model_id
    )
    , stg_tests_with_sk as (
        select distinct
            {{ dbt_utils.generate_surrogate_key(['test_id']) }} as test_sk
            , *
        from joined_tests_models
    )
select *
from stg_tests_with_sk
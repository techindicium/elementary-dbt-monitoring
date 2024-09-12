with
    models_details as (
        /* Extract models info from the staging table */
        select *
        from {{ ref('stg_dbt_models') }}
    )

    , models_scd_rules as (
        /* SCD rules */
        select 
            *
            ,  case
                when row_number() over (
                    partition by unique_id 
                    order by generated_at desc
                    ) = 1 
                    then True
                else False
            end as most_recent_info
            , generated_at as begin_generated_at
            , lag(generated_at, 1) over (
                partition by unique_id 
                order by generated_at desc
            ) as end_generated_at
        from models_details
    )

    , primary_key as (
        select 
            {{ dbt_utils.generate_surrogate_key(['unique_id']) }} as dim_models_pk
            , models_scd_rules.*
        from models_scd_rules
    )

select *
from primary_key

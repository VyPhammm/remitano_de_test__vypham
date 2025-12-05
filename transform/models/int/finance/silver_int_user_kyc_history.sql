--- Insert new record and replace effective_to (in old record) by effective_from of the new record.

{{ config(
    materialized='incremental',
    unique_key= 'int_key',
    incremental_strategy='merge',
    on_schema_change: 'append_new_column'
    post_hook=[
     "
     MERGE INTO {{ this }} AS target
     USING {{ this }}__stg AS source
     ON target.user_id = source.user_id
     WHEN MATCHED 
        AND target.effective_to IS NULL
        AND target.kyc_level <> source.kyc_level
     THEN UPDATE SET effective_to = source.effective_from

     WHEN NOT MATCHED THEN
       INSERT (user_id, kyc_level, effective_from, effective_to, int_key)
       VALUES (source.user_id, source.kyc_level, source.effective_from, NULL, source.int_key);
     "
   ] 
) }}

WITH source AS (
    SELECT
        user_id,
        kyc_level,
        updated_at AS effective_from
    FROM {{ ref('bronze_stg_users') }}
)
, stagged AS (
    SELECT
        {{ dbt_utils.surrogate_key(['user_id', 'kyc_level', 'effective_from']) }} AS int_key,
        user_id,
        kyc_level,
        effective_from,
        NULL AS effective_to
    FROM source
)

SELECT *
FROM stagged
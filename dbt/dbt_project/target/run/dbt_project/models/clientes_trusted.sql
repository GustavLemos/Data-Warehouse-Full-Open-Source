
  create view "warehouse"."public"."clientes_trusted__dbt_tmp"
    
    
  as (
    

SELECT
  nome_item,
  periodo,
  custo_estimado,
  uuid
FROM "warehouse"."public"."Simple_Sheets"
WHERE nome_item ILIKE 'EC2 %'
  );
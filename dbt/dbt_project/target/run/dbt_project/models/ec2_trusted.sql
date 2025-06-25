
  create view "warehouse"."public"."ec2_trusted__dbt_tmp"
    
    
  as (
    

SELECT
  "Componente",
  "Qtd_Unidade",
  "Datas_Previstas",
  "Custo_Maximo__USD_",
  "Custo_Minimo__USD_",
  "Objetivo_na_Arquitetura",
  "Custo_Total_Estimado__BRL_",
  "Custo_Total_Estimado__USD_",
  "Descricao_Tecnica_da_Funcao"
FROM "warehouse"."public"."Simple_sheets"
WHERE "Componente" ILIKE 'EC2 %'
  );
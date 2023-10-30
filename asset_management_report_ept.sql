SELECT
   id,
   asm_name,
   asm_date,
   asm_partner_id,
   s_sale_id,
   t_task_id,
   job_no
FROM
   (
      (
         SELECT
            row_number() OVER (
               ORDER BY
                  asm.id,
                  COALESCE(s.sale_id, 0),
                  COALESCE(t.task_id, 0)
            ) AS id,
            asm.name AS asm_name,
            asm.date AS asm_date,
            asm.partner_id AS asm_partner_id,
            s.sale_id AS s_sale_id,
            t.task_id AS t_task_id,
            ('Job ' :: text || task.job_no) AS job_no
         FROM
            (
               (
                  (
                     asset_management_ept asm
                     LEFT JOIN sale_order_asset_inventory_rel s ON (
                        (
                           asm.id = s.asset_id
                        )
                     )
                  )
                  LEFT JOIN task_asset_inventory_rel t ON (
                     (
                        asm.id = t.asset_id
                     )
                  )
               )
               LEFT JOIN project_task task ON (
                  (
                     task.id = t.task_id
                  )
               )
            )
         WHERE
            (
               (
                  EXISTS (
                     SELECT
                        DISTINCT 1
                     FROM
                        task_asset_inventory_rel
                     WHERE
                        (
                           asm.id = task_asset_inventory_rel.asset_id
                        )
                  )
               )
            )
      )
      UNION
      DISTINCT (
         SELECT
            row_number() OVER (
               ORDER BY
                  asm.id,
                  COALESCE(s.sale_id, 0),
                  COALESCE(t.task_id, 0)
            ) AS id,
            asm.name AS asm_name,
            asm.date AS asm_date,
            asm.partner_id AS asm_partner_id,
            s.sale_id AS s_sale_id,
            t.task_id AS t_task_id,
            ('Job ' :: text || task.job_no) AS job_no
         FROM
            (
               (
                  (
                     asset_management_ept asm
                     LEFT JOIN sale_order_asset_inventory_rel s ON ((asm.id = s.asset_id))
                  )
                  LEFT JOIN task_asset_inventory_rel t ON ((asm.id = t.asset_id))
               )
               LEFT JOIN project_task task ON ((task.id = t.task_id))
            )
         WHERE
            (
               (
                  EXISTS (
                     SELECT
                        DISTINCT 1
                     FROM
                        sale_order_asset_inventory_rel
                     WHERE
                        (asm.id = sale_order_asset_inventory_rel.asset_id)
                  )
               )
            )
      )
   ) AS union1
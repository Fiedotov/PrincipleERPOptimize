WITH sales_data AS (
  SELECT
    pts.product_id,
    pts.qty,
    (pt.create_date) :: date AS date,
    mv.location_id
  FROM
    project_task_stock pts,
    project_task pt,
    stock_move mv
  WHERE
    (
      (pts.task_id = pt.id)
      AND (
        pt.create_date > ((('now' :: text) :: date - '90 days' :: interval day)) :: date
      )
      AND ((pts.delivered_qty) :: double precision >= pts.qty)
      AND (mv.task_stock_id = pts.id)
    )
  UNION
  ALL
  SELECT
    sol.product_id,
    sol.product_uom_qty,
    so.date_confirm,
    mv.location_id
  FROM
    sale_order_line sol,
    sale_order so,
    stock_move mv
  WHERE
    (
      (
        (so.state) :: text <> ALL (
          (
            ARRAY ['draft'::character varying, 'sent'::character varying, 'cancel'::character varying]
          ) :: text []
        )
      )
      AND (sol.order_id = so.id)
      AND (
        so.date_order > ((('now' :: text) :: date - '90 days' :: interval day)) :: date
      )
      AND (mv.sale_line_id = sol.id)
    )
),
unique_ids AS (
  SELECT
    row_number() OVER (
      ORDER BY
        p.id,
        w.id
    ) AS id,
    w.id AS warehouse_id,
    p.id AS product_id
  FROM
    stock_warehouse w,
    product_product p
  WHERE
    (w.active = true)
  ORDER BY
    p.id,
    w.id
)
SELECT
  uq.id,
  sd.product_id,
  sum(sd.qty) AS sold,
  90 AS days,
  round(
    ((sum(sd.qty) / (90) :: double precision)) :: numeric,
    2
  ) AS avg_daily_sale,
  round(
    (
      (
        (sum(sd.qty) / (90) :: double precision) * (30.4166) :: double precision
      )
    ) :: numeric,
    2
  ) AS avg_monthly_sale,
  war.id AS warehouse_id
FROM
  sales_data sd,
  stock_location loc,
  stock_warehouse war,
  unique_ids uq
WHERE
  (
    (sd.location_id = loc.id)
    AND (war.lot_stock_id = loc.id)
    AND (uq.product_id = sd.product_id)
    AND (uq.warehouse_id = war.id)
  )
GROUP BY
  sd.product_id,
  war.id,
  uq.id
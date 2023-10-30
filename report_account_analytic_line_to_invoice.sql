SELECT
  DISTINCT to_char((l.date) :: timestamp with time zone, 'MM' :: text) AS month,
  to_char((l.date) :: timestamp with time zone, 'YYYY' :: text) AS name,
  min(l.id) AS id,
  l.product_id,
  l.account_id,
  sum(l.amount) AS amount,
  sum(
    (l.unit_amount * (t.list_price) :: double precision)
  ) AS sale_price,
  sum(l.unit_amount) AS unit_amount,
  l.product_uom_id
FROM
  (
    (
      account_analytic_line l
      LEFT JOIN product_product p ON ((l.product_id = p.id))
    )
    LEFT JOIN product_template t ON ((p.product_tmpl_id = t.id))
  )
WHERE
  (
    (l.invoice_id IS NULL)
    AND (l.to_invoice IS NOT NULL)
  )
GROUP BY
  (
    to_char((l.date) :: timestamp with time zone, 'YYYY' :: text)
  ),
  (
    to_char((l.date) :: timestamp with time zone, 'MM' :: text)
  ),
  l.product_id,
  l.product_uom_id,
  l.account_id
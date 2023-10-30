SELECT
  min(t.id) AS id,
  l.date,
  to_char(
    (l.date) :: timestamp with time zone,
    'YYYY-MM-DD' :: text
  ) AS day,
  to_char((l.date) :: timestamp with time zone, 'YYYY' :: text) AS year,
  to_char((l.date) :: timestamp with time zone, 'MM' :: text) AS month,
  sum(l.amount) AS cost,
  sum(l.unit_amount) AS quantity,
  l.account_id,
  l.journal_id,
  l.product_id,
  l.general_account_id,
  l.user_id,
  l.company_id,
  l.currency_id
FROM
  (
    hr_analytic_timesheet t
    LEFT JOIN account_analytic_line l ON ((t.line_id = l.id))
  )
GROUP BY
  l.date,
  l.account_id,
  l.product_id,
  l.general_account_id,
  l.journal_id,
  l.user_id,
  l.company_id,
  l.currency_id
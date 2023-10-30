SELECT
  l.id,
  l.partner_id,
  min(l.date) AS date_move,
  max(l.date) AS date_move_last,
  max(l.followup_date) AS date_followup,
  max(l.followup_line_id) AS followup_id,
  sum(l.debit) AS debit,
  sum(l.credit) AS credit,
  sum((l.debit - l.credit)) AS balance,
  l.company_id,
  l.blocked,
  l.period_id
FROM
  (
    account_move_line l
    LEFT JOIN account_account a ON ((l.account_id = a.id))
  )
WHERE
  (
    a.active
    AND ((a.type) :: text = 'receivable' :: text)
    AND (l.reconcile_id IS NULL)
    AND (l.partner_id IS NOT NULL)
  )
GROUP BY
  l.id,
  l.partner_id,
  l.company_id,
  l.blocked,
  l.period_id
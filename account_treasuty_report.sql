SELECT
   p.id,
   p.fiscalyear_id,
   p.id AS period_id,
   sum(l.debit) AS debit,
   sum(l.credit) AS credit,
   sum((l.debit - l.credit)) AS balance,
   p.date_start AS date,
   am.company_id
FROM
   (
      (
         (
            (SELECT debit, credit, account_id, move_id, state FROM account_move_line) l
            LEFT JOIN (SELECT id, type FROM account_account) a ON ((l.account_id = a.id))
         )
         LEFT JOIN (SELECT id, period_id, company_id FROM account_move) am ON ((am.id = l.move_id))
      )
      LEFT JOIN (SELECT id, fiscalyear_id, date_start FROM account_period) p ON ((am.period_id = p.id))
   )
WHERE
   (
      ((l.state) :: text <> 'draft' :: text)
      AND ((a.type) :: text = 'liquidity' :: text)
   )
GROUP BY
   p.id,
   p.fiscalyear_id,
   p.date_start,
   am.company_id
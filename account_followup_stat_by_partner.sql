SELECT
    ((l.partner_id * 10000) + l.company_id) AS id,
    l.partner_id,
    min(l.date) AS date_move,
    max(l.date) AS date_move_last,
    max(l.followup_date) AS date_followup,
    max(l.followup_line_id) AS max_followup_id,
    sum((l.debit - l.credit)) AS balance,
    l.company_id
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
        AND (l.blocked = false)
    )
GROUP BY
    l.partner_id,
    l.company_id
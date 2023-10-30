SELECT
    aged_partner_balance_report_ept.partner_id,
    sum(aged_partner_balance_report_ept.amount_due) AS amount_due,
    sum(aged_partner_balance_report_ept.due_days_30) AS due_days_30,
    sum(aged_partner_balance_report_ept.due_days_60) AS due_days_60,
    sum(aged_partner_balance_report_ept.due_days_90) AS due_days_90,
    sum(aged_partner_balance_report_ept.due_days_120) AS due_days_120,
    sum(aged_partner_balance_report_ept.amount_credit) AS amount_credit,
    sum(aged_partner_balance_report_ept.amount_balance) AS amount_balance,
    min(aged_partner_balance_report_ept.id) AS id
FROM
    aged_partner_balance_report_ept
GROUP BY
    aged_partner_balance_report_ept.partner_id
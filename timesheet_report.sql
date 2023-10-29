SELECT
    min(aal.id) AS id,
    aal.date,
    count(*) AS nbr,
    aal.unit_amount AS quantity,
    aal.amount AS cost,
    aal.account_id,
    aal.product_id,
    aal.to_invoice,
    aal.general_account_id
FROM
    (
        (
            account_analytic_line aal
            LEFT JOIN hr_analytic_timesheet hat ON ((hat.line_id = aal.id))
        )
        LEFT JOIN hr_timesheet_sheet_sheet htss ON ((hat.sheet_id = htss.id))
    )
GROUP BY
    aal.account_id,
    aal.date,
    htss.date_from,
    htss.date_to,
    aal.unit_amount,
    aal.amount,
    aal.to_invoice,
    aal.product_id,
    aal.general_account_id,
    htss.name,
    htss.company_id,
    htss.state,
    htss.id,
    htss.department_id,
    htss.user_id
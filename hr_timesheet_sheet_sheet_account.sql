 SELECT min(hrt.id) AS id,
    l.account_id AS name,
    s.id AS sheet_id,
    sum(l.unit_amount) AS total,
    l.to_invoice AS invoice_rate
   FROM (hr_analytic_timesheet hrt
     LEFT JOIN (account_analytic_line l
     LEFT JOIN hr_timesheet_sheet_sheet s ON (((s.date_to >= l.date) AND (s.date_from <= l.date) AND (s.user_id = l.user_id)))) ON ((l.id = hrt.line_id)))
  GROUP BY l.account_id, s.id, l.to_invoice
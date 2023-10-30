SELECT l.id,
    am.date,
    l.date_maturity,
    l.date_created,
    am.ref,
    am.state AS move_state,
    l.state AS move_line_state,
    l.reconcile_id,
    to_char((am.date)::timestamp with time zone, 'YYYY'::text) AS year,
    to_char((am.date)::timestamp with time zone, 'MM'::text) AS month,
    to_char((am.date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS day,
    l.partner_id,
    l.product_id,
    l.product_uom_id,
    am.company_id,
    am.journal_id,
    p.fiscalyear_id,
    am.period_id,
    l.account_id,
    l.analytic_account_id,
    a.type,
    a.user_type,
    1 AS nbr,
    l.quantity,
    l.currency_id,
    l.amount_currency,
    l.debit,
    l.credit,
    (COALESCE(l.debit, 0.0) - COALESCE(l.credit, 0.0)) AS balance
   FROM ((((SELECT id, date_maturity, date_created, state, reconcile_id, partner_id, product_id, product_uom_id, account_id, analytic_account_id, quantity, currency_id, amount_currency, debit, credit FROM account_move_line) l
     LEFT JOIN (SELECT id, type, user_type FROM account_account) a ON ((l.account_id = a.id)))
     LEFT JOIN (SELECT id, date, ref, state, company_id, journal_id, period_id FROM account_move) am ON ((am.id = l.move_id)))
     LEFT JOIN (SELECT id, fiscalyear_id FROM account_period) p ON ((am.period_id = p.id)))
  WHERE ((l.state)::text <> 'draft'::text)
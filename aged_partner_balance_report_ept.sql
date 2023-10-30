SELECT
    min(am.id) AS id,
    ai.id AS invoice_id,
    ai.date_invoice AS date,
    ai.partner_id,
    ai.number AS name,
    CASE
        WHEN (
            (ai.type) :: text = ANY (
                ARRAY [('out_invoice'::character varying)::text, ('in_refund'::character varying)::text]
            )
        ) THEN 'invoice' :: text
        ELSE 'credit' :: text
    END AS ttype,
    COALESCE(
        sum(ai.amount_total) FILTER (
            WHERE
                (
                    (ai.type) :: text = ANY (
                        ARRAY [('out_invoice'::character varying)::text, ('in_refund'::character varying)::text]
                    )
                )
        ),
        0.0
    ) AS amount_invoice,
    COALESCE(
        sum((ai.amount_total - ai.residual)) FILTER (
            WHERE
                (
                    (ai.type) :: text = ANY (
                        ARRAY [('out_invoice'::character varying)::text, ('in_refund'::character varying)::text]
                    )
                )
        ),
        0.0
    ) AS amount_invoice_paid,
    sum(0.0) AS amount_credit,
    COALESCE(
        sum(ai.residual) FILTER (
            WHERE
                (
                    (ai.type) :: text = ANY (
                        ARRAY [('out_invoice'::character varying)::text, ('in_refund'::character varying)::text]
                    )
                )
        ),
        0.0
    ) AS amount_balance,
    COALESCE(
        sum(ai.residual) FILTER (
            WHERE
                (
                    (ai.type) :: text = ANY (
                        ARRAY [('out_invoice'::character varying)::text, ('in_refund'::character varying)::text]
                    )
                )
        ),
        0.0
    ) AS amount_due,
    COALESCE(
        sum(ai.residual) FILTER (
            WHERE
                (
                    (
                        (ai.type) :: text = ANY (
                            ARRAY [('out_invoice'::character varying)::text, ('in_refund'::character varying)::text]
                        )
                    )
                    AND (ai.date_invoice IS NOT NULL)
                    AND (
                        date_part(
                            'day' :: text,
                            (
                                now() - (ai.date_invoice) :: timestamp with time zone
                            )
                        ) < (30) :: double precision
                    )
                )
        ),
        0.0
    ) AS due_days_30,
    COALESCE(
        sum(ai.residual) FILTER (
            WHERE
                (
                    (
                        (ai.type) :: text = ANY (
                            ARRAY [('out_invoice'::character varying)::text, ('in_refund'::character varying)::text]
                        )
                    )
                    AND (ai.date_invoice IS NOT NULL)
                    AND (
                        date_part(
                            'day' :: text,
                            (
                                now() - (ai.date_invoice) :: timestamp with time zone
                            )
                        ) < (60) :: double precision
                    )
                    AND (
                        date_part(
                            'day' :: text,
                            (
                                now() - (ai.date_invoice) :: timestamp with time zone
                            )
                        ) >= (30) :: double precision
                    )
                )
        ),
        0.0
    ) AS due_days_60,
    COALESCE(
        sum(ai.residual) FILTER (
            WHERE
                (
                    (
                        (ai.type) :: text = ANY (
                            ARRAY [('out_invoice'::character varying)::text, ('in_refund'::character varying)::text]
                        )
                    )
                    AND (ai.date_invoice IS NOT NULL)
                    AND (
                        date_part(
                            'day' :: text,
                            (
                                now() - (ai.date_invoice) :: timestamp with time zone
                            )
                        ) < (90) :: double precision
                    )
                    AND (
                        date_part(
                            'day' :: text,
                            (
                                now() - (ai.date_invoice) :: timestamp with time zone
                            )
                        ) >= (60) :: double precision
                    )
                )
        ),
        0.0
    ) AS due_days_90,
    COALESCE(
        sum(ai.residual) FILTER (
            WHERE
                (
                    (
                        (ai.type) :: text = ANY (
                            ARRAY [('out_invoice'::character varying)::text, ('in_refund'::character varying)::text]
                        )
                    )
                    AND (ai.date_invoice IS NOT NULL)
                    AND (
                        date_part(
                            'day' :: text,
                            (
                                now() - (ai.date_invoice) :: timestamp with time zone
                            )
                        ) >= (90) :: double precision
                    )
                )
        ),
        0.0
    ) AS due_days_120
FROM
    (
        account_invoice ai
        LEFT JOIN account_move am ON ((am.id = ai.move_id))
    )
WHERE
    ((ai.state) :: text = 'open' :: text)
GROUP BY
    ai.id,
    ai.date_invoice,
    ai.partner_id,
    ai.number,
    CASE
        WHEN (
            (ai.type) :: text = ANY (
                ARRAY [('out_invoice'::character varying)::text, ('in_refund'::character varying)::text]
            )
        ) THEN 'invoice' :: text
        ELSE 'credit' :: text
    END
UNION
ALL
SELECT
    min(am.id) AS id,
    0 AS invoice_id,
    aml.date,
    aml.partner_id,
    aml.ref AS name,
    'credit' :: text AS ttype,
    sum(0.0) AS amount_invoice,
    sum(0.0) AS amount_invoice_paid,
    COALESCE(sum((aml.credit - aml.debit)), 0.0) AS amount_credit,
    COALESCE(sum((aml.debit - aml.credit)), 0.0) AS amount_balance,
    sum(0.0) AS amount_due,
    sum(0.0) AS due_days_30,
    sum(0.0) AS due_days_60,
    sum(0.0) AS due_days_90,
    sum(0.0) AS due_days_120
FROM
    (
        account_move_line aml
        LEFT JOIN account_move am ON ((am.id = aml.move_id))
    )
WHERE
    (
        (
            aml.account_id IN (
                SELECT
                    account_account.id
                FROM
                    account_account
                WHERE
                    (
                        (account_account.reconcile = true)
                        AND (
                            (account_account.type) :: text = ANY (
                                ARRAY [('receivable'::character varying)::text, ('payable'::character varying)::text]
                            )
                        )
                    )
            )
        )
        AND (
            aml.move_id IN (
                SELECT
                    account_invoice.move_id
                FROM
                    account_invoice
                WHERE
                    (account_invoice.id IS NULL)
            )
        )
        AND (aml.reconcile_id IS NULL)
        AND (aml.reconcile_partial_id IS NULL)
    )
GROUP BY
    0 :: integer,
    aml.date,
    aml.partner_id,
    aml.ref,
    'credit' :: text
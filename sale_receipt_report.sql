SELECT
    min(avl.id) AS id,
    av.date,
    to_char(
        (av.date) :: timestamp with time zone,
        'YYYY' :: text
    ) AS year,
    to_char((av.date) :: timestamp with time zone, 'MM' :: text) AS month,
    to_char(
        (av.date) :: timestamp with time zone,
        'YYYY-MM-DD' :: text
    ) AS day,
    av.partner_id,
    aj.currency AS currency_id,
    av.journal_id,
    rp.user_id,
    av.company_id,
    count(avl.*) AS nbr,
    av.type,
    av.state,
    av.pay_now,
    av.date_due,
    av.account_id,
    (
        sum((av.amount - av.tax_amount)) / (
            (
                SELECT
                    count(l.id) AS count
                FROM
                    (
                        account_voucher_line l
                        LEFT JOIN account_voucher a ON ((a.id = l.voucher_id))
                    )
                WHERE
                    (a.id = av.id)
            )
        ) :: numeric
    ) AS price_total,
    (
        sum(av.amount) / (
            (
                SELECT
                    count(l.id) AS count
                FROM
                    (
                        account_voucher_line l
                        LEFT JOIN account_voucher a ON ((a.id = l.voucher_id))
                    )
                WHERE
                    (a.id = av.id)
            )
        ) :: numeric
    ) AS price_total_tax,
    sum(
        (
            SELECT
                (
                    date_part(
                        'epoch' :: text,
                        avg(
                            (
                                date_trunc(
                                    'day' :: text,
                                    (aml.date_created) :: timestamp with time zone
                                ) - (date_trunc('day' :: text, l.create_date)) :: timestamp with time zone
                            )
                        )
                    ) / ((((24 * 60) * 60)) :: numeric(16, 2)) :: double precision
                )
            FROM
                (
                    (
                        account_move_line aml
                        LEFT JOIN account_voucher a ON ((a.move_id = aml.move_id))
                    )
                    LEFT JOIN account_voucher_line l ON ((a.id = l.voucher_id))
                )
            WHERE
                (a.id = av.id)
        )
    ) AS delay_to_pay,
    sum(
        (
            SELECT
                (
                    date_part(
                        'epoch' :: text,
                        avg(
                            (
                                date_trunc(
                                    'day' :: text,
                                    (a.date_due) :: timestamp with time zone
                                ) - date_trunc('day' :: text, (a.date) :: timestamp with time zone)
                            )
                        )
                    ) / ((((24 * 60) * 60)) :: numeric(16, 2)) :: double precision
                )
            FROM
                (
                    (
                        account_move_line aml
                        LEFT JOIN account_voucher a ON ((a.move_id = aml.move_id))
                    )
                    LEFT JOIN account_voucher_line l ON ((a.id = l.voucher_id))
                )
            WHERE
                (a.id = av.id)
        )
    ) AS due_delay
FROM
    (
        (
            (
                account_voucher_line avl
                LEFT JOIN account_voucher av ON ((av.id = avl.voucher_id))
            )
            LEFT JOIN res_partner rp ON ((rp.id = av.partner_id))
        )
        LEFT JOIN account_journal aj ON ((aj.id = av.journal_id))
    )
WHERE
    (
        ((av.type) :: text = 'sale' :: text)
        AND (
            (aj.type) :: text = ANY (
                (
                    ARRAY ['sale'::character varying, 'sale_refund'::character varying]
                ) :: text []
            )
        )
    )
GROUP BY
    av.date,
    av.id,
    (
        to_char(
            (av.date) :: timestamp with time zone,
            'YYYY' :: text
        )
    ),
    (
        to_char((av.date) :: timestamp with time zone, 'MM' :: text)
    ),
    (
        to_char(
            (av.date) :: timestamp with time zone,
            'YYYY-MM-DD' :: text
        )
    ),
    av.partner_id,
    aj.currency,
    av.journal_id,
    rp.user_id,
    av.company_id,
    av.type,
    av.state,
    av.date_due,
    av.account_id,
    av.tax_amount,
    av.amount,
    av.pay_now
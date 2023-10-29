SELECT
    (
        (
            to_number(
                to_char(d.month, 'YYYYMM' :: text),
                '999999' :: text
            ) + ((d.account_id * (1000000) :: bigint)) :: numeric
        )
    ) :: bigint AS id,
    d.account_id,
    to_char(d.month, 'Mon YYYY' :: text) AS month,
    to_number(
        to_char(d.month, 'YYYYMM' :: text),
        '999999' :: text
    ) AS month_id,
    COALESCE(sum(l.unit_amount), (0.0) :: double precision) AS unit_amount
FROM
    (
        (
            SELECT
                a.id AS account_id,
                l_1.month
            FROM
                (
                    SELECT
                        date_trunc(
                            'month' :: text,
                            (l_2.date) :: timestamp with time zone
                        ) AS month
                    FROM
                        account_analytic_line l_2,
                        account_analytic_journal j
                    WHERE
                        ((j.type) :: text = 'general' :: text)
                    GROUP BY
                        (
                            date_trunc(
                                'month' :: text,
                                (l_2.date) :: timestamp with time zone
                            )
                        )
                    ORDER BY
                        month
                ) l_1,
                (
                    SELECT
                        id
                    FROM
                        account_analytic_account
                ) a
        ) d
        LEFT JOIN (
            SELECT
                l_1.account_id,
                date_trunc(
                    'month' :: text,
                    (l_1.date) :: timestamp with time zone
                ) AS month,
                sum(l_1.unit_amount) AS unit_amount
            FROM
                account_analytic_line l_1,
                account_analytic_journal j
            WHERE
                (
                    ((j.type) :: text = 'general' :: text)
                    AND (j.id = l_1.journal_id)
                )
            GROUP BY
                l_1.account_id,
                (
                    date_trunc(
                        'month' :: text,
                        (l_1.date) :: timestamp with time zone
                    )
                )
        ) l ON (
            (
                (d.account_id = l.account_id)
                AND (d.month = l.month)
            )
        )
    )
GROUP BY
    d.month,
    d.account_id
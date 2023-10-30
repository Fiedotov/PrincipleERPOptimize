SELECT
    bar.id,
    bar.name,
    bar.sheet_id,
    bar.total_timesheet,
    bar.total_attendance,
    (
        round(
            ((bar.total_attendance - bar.total_timesheet)) :: numeric,
            2
        )
    ) :: double precision AS total_difference
FROM
    (
        SELECT
            max(foo.id) AS id,
            foo.name,
            foo.sheet_id,
            foo.timezone,
            sum(foo.total_timesheet) AS total_timesheet,
            (
                CASE
                    WHEN (sum(foo.orphan_attendances) <> (0) :: numeric) THEN (
                        sum(foo.total_attendance) + CASE
                            WHEN (('now' :: text) :: date <> foo.name) THEN (1440) :: double precision
                            ELSE (
                                (
                                    date_part(
                                        'hour' :: text,
                                        timezone(
                                            (COALESCE(foo.timezone, 'UTC' :: character varying)) :: text,
                                            timezone('UTC' :: text, ('now' :: text) :: time with time zone)
                                        )
                                    ) * (60) :: double precision
                                ) + date_part(
                                    'minute' :: text,
                                    timezone(
                                        (COALESCE(foo.timezone, 'UTC' :: character varying)) :: text,
                                        timezone('UTC' :: text, ('now' :: text) :: time with time zone)
                                    )
                                )
                            )
                        END
                    )
                    ELSE sum(foo.total_attendance)
                END / (60) :: double precision
            ) AS total_attendance
        FROM
            (
                SELECT
                    min(hrt.id) AS id,
                    p.tz AS timezone,
                    l.date AS name,
                    s.id AS sheet_id,
                    sum(l.unit_amount) AS total_timesheet,
                    0 AS orphan_attendances,
                    0.0 AS total_attendance
                FROM
                    (
                        (
                            (
                                (
                                    (
                                        (
                                            hr_analytic_timesheet hrt
                                            JOIN account_analytic_line l ON ((l.id = hrt.line_id))
                                        )
                                        LEFT JOIN hr_timesheet_sheet_sheet s ON ((s.id = hrt.sheet_id))
                                    )
                                    JOIN hr_employee e ON ((s.employee_id = e.id))
                                )
                                JOIN resource_resource r ON ((e.resource_id = r.id))
                            )
                            LEFT JOIN res_users u ON ((r.user_id = u.id))
                        )
                        LEFT JOIN res_partner p ON ((u.partner_id = p.id))
                    )
                GROUP BY
                    l.date,
                    s.id,
                    p.tz
                UNION
                SELECT
                    (- min(a.id)) AS id,
                    p.tz AS timezone,
                    (
                        timezone(
                            (COALESCE(p.tz, 'UTC' :: character varying)) :: text,
                            timezone('UTC' :: text, a.name)
                        )
                    ) :: date AS name,
                    s.id AS sheet_id,
                    0.0 AS total_timesheet,
                    sum(
                        CASE
                            WHEN ((a.action) :: text = 'sign_in' :: text) THEN '-1' :: integer
                            ELSE 1
                        END
                    ) AS orphan_attendances,
                    sum(
                        (
                            (
                                (
                                    date_part(
                                        'hour' :: text,
                                        timezone(
                                            (COALESCE(p.tz, 'UTC' :: character varying)) :: text,
                                            timezone('UTC' :: text, a.name)
                                        )
                                    ) * (60) :: double precision
                                ) + date_part(
                                    'minute' :: text,
                                    timezone(
                                        (COALESCE(p.tz, 'UTC' :: character varying)) :: text,
                                        timezone('UTC' :: text, a.name)
                                    )
                                )
                            ) * (
                                CASE
                                    WHEN ((a.action) :: text = 'sign_in' :: text) THEN '-1' :: integer
                                    ELSE 1
                                END
                            ) :: double precision
                        )
                    ) AS total_attendance
                FROM
                    (
                        (
                            (
                                (
                                    (
                                        hr_attendance a
                                        LEFT JOIN hr_timesheet_sheet_sheet s ON ((s.id = a.sheet_id))
                                    )
                                    JOIN hr_employee e ON ((a.employee_id = e.id))
                                )
                                JOIN resource_resource r ON ((e.resource_id = r.id))
                            )
                            LEFT JOIN res_users u ON ((r.user_id = u.id))
                        )
                        LEFT JOIN res_partner p ON ((u.partner_id = p.id))
                    )
                WHERE
                    (
                        (a.action) :: text = ANY (
                            (
                                ARRAY ['sign_in'::character varying, 'sign_out'::character varying]
                            ) :: text []
                        )
                    )
                GROUP BY
                    (
                        (
                            timezone(
                                (COALESCE(p.tz, 'UTC' :: character varying)) :: text,
                                timezone('UTC' :: text, a.name)
                            )
                        ) :: date
                    ),
                    s.id,
                    p.tz
            ) foo
        GROUP BY
            foo.name,
            foo.sheet_id,
            foo.timezone
    ) bar
SELECT
        ((((r.id * 12))::numeric + to_number(months.m_id,
        '999999'::text)))::integer AS id,
        months.name,
        r.id AS user_id,
        to_char((to_date(months.name,
        'YYYY/MM/DD'::text))::timestamp with time zone,
        'YYYY'::text) AS year,
        to_char((to_date(months.name,
        'YYYY/MM/DD'::text))::timestamp with time zone,
        'MM'::text) AS month,
        (SELECT
            sum(project_task_work.hours) AS sum 
        FROM
            project_task_work 
        WHERE
            (
                (
                    project_task_work.user_id = r.id
                ) 
                AND (
                    (
                        project_task_work.date >= to_date(months.name, 'YYYY/MM/DD'::text)
                    ) 
                    AND (
                        project_task_work.date <= (
                            (
                                to_date(months.name, 'YYYY/MM/DD'::text) + '1 mon'::interval
                            ) - '1 day'::interval
                        )
                    )
                )
            )) AS task_hrs 
    FROM
        res_users r,
        (SELECT
            to_char(p.date,
            'YYYY-MM-01'::text) AS name,
            to_char(p.date,
            'YYYYMM'::text) AS m_id 
        FROM
            project_task_work p 
        UNION
        SELECT
            to_char((h.name)::timestamp with time zone,
            'YYYY-MM-01'::text) AS name,
            to_char((h.name)::timestamp with time zone,
            'YYYYMM'::text) AS m_id 
        FROM
            hr_timesheet_sheet_sheet_day h
    ) months 
GROUP BY
    r.id,
    months.m_id,
    months.name,
    (to_char((to_date(months.name,
    'YYYY/MM/DD'::text))::timestamp with time zone,
    'YYYY'::text)),
    (to_char((to_date(months.name,
    'YYYY/MM/DD'::text))::timestamp with time zone,
    'MM'::text))
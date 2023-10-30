SELECT
    c.id,
    to_char(
        (c.date_deadline) :: timestamp with time zone,
        'YYYY' :: text
    ) AS deadline_year,
    to_char(
        (c.date_deadline) :: timestamp with time zone,
        'MM' :: text
    ) AS deadline_month,
    to_char(
        (c.date_deadline) :: timestamp with time zone,
        'YYYY-MM-DD' :: text
    ) AS deadline_day,
    to_char(c.create_date, 'YYYY' :: text) AS creation_year,
    to_char(c.create_date, 'MM' :: text) AS creation_month,
    to_char(c.create_date, 'YYYY-MM-DD' :: text) AS creation_day,
    to_char(c.date_open, 'YYYY-MM-DD' :: text) AS opening_date,
    to_char(c.date_closed, 'YYYY-mm-dd' :: text) AS date_closed,
    c.state,
    c.user_id,
    c.probability,
    c.stage_id,
    c.type,
    c.company_id,
    c.priority,
    c.section_id,
    c.channel_id,
    c.type_id,
    c.partner_id,
    c.country_id,
    c.planned_revenue,
    (
        c.planned_revenue * (c.probability / (100) :: double precision)
    ) AS probable_revenue,
    1 AS nbr,
    date_trunc('day' :: text, c.create_date) AS create_date,
    (
        date_part('epoch' :: text, (c.date_closed - c.create_date)) / ((3600 * 24)) :: double precision
    ) AS delay_close,
    abs(
        (
            date_part(
                'epoch' :: text,
                (
                    (c.date_deadline) :: timestamp without time zone - c.date_closed
                )
            ) / ((3600 * 24)) :: double precision
        )
    ) AS delay_expected,
    (
        date_part('epoch' :: text, (c.date_open - c.create_date)) / ((3600 * 24)) :: double precision
    ) AS delay_open
FROM
    crm_lead c
WHERE
    (c.active = true)
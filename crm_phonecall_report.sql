SELECT
    c.id,
    to_char(c.date, 'YYYY' :: text) AS name,
    to_char(c.date, 'MM' :: text) AS month,
    to_char(c.date, 'YYYY-MM-DD' :: text) AS day,
    to_char(c.create_date, 'YYYY-MM-DD' :: text) AS creation_date,
    to_char(c.date_open, 'YYYY-MM-DD' :: text) AS opening_date,
    to_char(c.date_closed, 'YYYY-mm-dd' :: text) AS date_closed,
    c.state,
    c.user_id,
    c.section_id,
    c.categ_id,
    c.partner_id,
    c.duration,
    c.company_id,
    c.priority,
    1 AS nbr,
    date_trunc('day' :: text, c.create_date) AS create_date,
    (
        date_part('epoch' :: text, (c.date_closed - c.create_date)) / ((3600 * 24)) :: double precision
    ) AS delay_close,
    (
        date_part('epoch' :: text, (c.date_open - c.create_date)) / ((3600 * 24)) :: double precision
    ) AS delay_open
FROM
    crm_phonecall c
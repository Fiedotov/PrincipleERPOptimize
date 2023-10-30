SELECT
       c.id,
       to_char(c.create_date, 'YYYY' :: text) AS name,
       to_char(c.create_date, 'MM' :: text) AS month,
       to_char(c.create_date, 'YYYY-MM-DD' :: text) AS day,
       to_char(c.date_open, 'YYYY-MM-DD' :: text) AS opening_date,
       to_char(c.create_date, 'YYYY-MM-DD' :: text) AS creation_date,
       c.state,
       c.user_id,
       c.working_hours_open,
       c.working_hours_close,
       c.section_id,
       c.stage_id,
       to_char(c.date_closed, 'YYYY-mm-dd' :: text) AS date_closed,
       c.company_id,
       c.priority,
       c.project_id,
       c.version_id,
       1 AS nbr,
       c.partner_id,
       c.channel_id,
       c.task_id,
       date_trunc('day' :: text, c.create_date) AS create_date,
       c.day_open AS delay_open,
       c.day_close AS delay_close,
       (
              SELECT
                     count(mail_message.id) AS count
              FROM
                     mail_message
              WHERE
                     (
                            (
                                   (mail_message.model) :: text = 'project.issue' :: text
                            )
                            AND (mail_message.res_id = c.id)
                     )
       ) AS email
FROM
       project_issue c
WHERE
       (c.active = true)
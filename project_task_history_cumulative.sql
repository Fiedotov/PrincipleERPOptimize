SELECT
    (
        (
            ((history.date) :: character varying) :: text || '-' :: text
        ) || ((history.history_id) :: character varying) :: text
    ) AS id,
    history.date AS end_date,
    history.history_id,
    history.date,
    history.task_id,
    history.type_id,
    history.user_id,
    history.kanban_state,
    history.state,
    history.remaining_hours,
    history.planned_hours,
    history.project_id
FROM
    (
        SELECT
            h.id AS history_id,
            (
                h.date + generate_series(
                    0,
                    (
                        (
                            COALESCE(h.end_date, '2017-06-23' :: date) - h.date
                        ) - 1
                    )
                )
            ) AS date,
            h.task_id,
            h.type_id,
            h.user_id,
            h.kanban_state,
            h.state,
            GREATEST(h.remaining_hours, (1) :: numeric) AS remaining_hours,
            GREATEST(h.planned_hours, (1) :: numeric) AS planned_hours,
            t.project_id
        FROM
            (
                (SELECT id, task_id, type_id, user_id, kanban_state, state, remaining_hours, planned_hours, date, end_date FROM project_task_history) h
                JOIN (SELECT id, project_id FROM project_task) t ON (
                    (
                        h.task_id = t.id
                    )
                )
            )
    ) history
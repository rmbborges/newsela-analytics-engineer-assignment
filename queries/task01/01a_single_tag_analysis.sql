-- -----------------------------------------------------------------------------
-- Query 1A: Single Tag Analysis
-- -----------------------------------------------------------------------------
WITH
questions AS (
    SELECT
        id AS question_id,
        LOWER(TRIM(tag)) AS tag,
        accepted_answer_id IS NOT NULL AS has_accepted_answer,
        answer_count
    FROM
        `bigquery-public-data.stackoverflow.posts_questions`
    LEFT JOIN
        UNNEST(SPLIT(tags, "|")) AS tag
    WHERE
        EXTRACT(year FROM creation_date) = 2022 
        AND tag IS NOT NULL
),
aggregated AS (
    SELECT
        tag,
        COUNT(DISTINCT(question_id)) AS total_questions_count,
        SUM(answer_count) AS total_answers_count,
        COUNTIF(has_accepted_answer) AS accepted_anwer_count,
        COUNTIF(has_accepted_answer)/COUNT(DISTINCT(question_id)) AS approved_answers_rate
    FROM
        questions
    GROUP BY
        tag
)
SELECT
    tag,
    total_questions_count,
    total_answers_count,
    accepted_anwer_count,
    approved_answers_rate,
    DENSE_RANK() OVER(
        ORDER BY
            total_answers_count DESC
    ) AS rank_total_answers_count,
    DENSE_RANK() OVER(
        ORDER BY
            approved_answers_rate DESC,
            total_answers_count DESC
    ) AS rank_approved_answers_rate
FROM
    aggregated
WHERE
    total_questions_count >= 1000
ORDER BY
    rank_total_answers_count

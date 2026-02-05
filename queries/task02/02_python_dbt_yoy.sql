-- =============================================================================
-- TASK 2: PYTHON VS DBT YEAR-OVER-YEAR ANALYSIS
-- =============================================================================
WITH
yearly_tags AS (
    SELECT
        id AS question_id,
        LOWER(TRIM(tags)) AS tag,
        EXTRACT(year FROM creation_date) AS creation_year,
        answer_count,
        accepted_answer_id IS NOT NULL AS has_accepted_answer
    FROM
        `bigquery-public-data.stackoverflow.posts_questions`
    WHERE
        creation_date >= '2012-01-01'
        AND LOWER(TRIM(tags)) IN ('dbt', 'python')
),
aggregation AS (
    SELECT
        creation_year,
        tag,
        COUNT(*) AS total_questions,
        COUNTIF(answer_count = 0) AS total_questions_to_answer,
        COUNTIF(has_accepted_answer) AS total_approved_answer,
        SAFE_DIVIDE(
            COUNTIF(answer_count = 0),
            COUNT(*)
        ) AS questions_to_answer_rate,
        SAFE_DIVIDE(
            COUNTIF(has_accepted_answer),
            COUNT(*)
        ) AS approved_answers_rate
    FROM
        yearly_tags
    GROUP BY
        creation_year,
        tag
)
SELECT
    creation_year,
    tag,
    total_questions,
    total_questions_to_answer,
    total_approved_answer,
    questions_to_answer_rate,
    approved_answers_rate,
    SAFE_DIVIDE(
        questions_to_answer_rate
        - LAG(questions_to_answer_rate) OVER(
            PARTITION BY tag
            ORDER BY creation_year
        ),
        LAG(questions_to_answer_rate) OVER(
            PARTITION BY tag
            ORDER BY creation_year
        )
    ) AS question_to_answer_rate_yoy_change,
    SAFE_DIVIDE(
        approved_answers_rate
        - LAG(approved_answers_rate) OVER(
            PARTITION BY tag
            ORDER BY creation_year
        ),
        LAG(approved_answers_rate) OVER(
            PARTITION BY tag
            ORDER BY creation_year
        )
    ) AS approved_answers_rate_yoy_change
FROM
    aggregation
ORDER BY 
    creation_year,
    tag DESC

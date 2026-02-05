-- -----------------------------------------------------------------------------
-- Query 3B: Veterancy
-- -----------------------------------------------------------------------------
WITH 
questions_ordered AS (
    SELECT
        id AS question_id,
        owner_user_id,
        answer_count,
        accepted_answer_id IS NOT NULL AS has_accepted_answer,
        ROW_NUMBER() OVER (
            PARTITION BY owner_user_id
            ORDER BY creation_date
        ) - 1 AS previous_questions_count
    FROM 
        `bigquery-public-data.stackoverflow.posts_questions`
    WHERE 
        creation_date >= '2013-01-01'
),
with_buckets AS (
    SELECT
        question_id,
        owner_user_id,
        answer_count,
        has_accepted_answer,
        CASE
            WHEN previous_questions_count = 0 THEN '1. First question'
            WHEN previous_questions_count BETWEEN 1 AND 10 THEN '2. 1-10 questions'
            WHEN previous_questions_count BETWEEN 11 AND 50 THEN '3. 11-50 questions'
            ELSE '4. 50+ questions'
        END AS questions_experience_bucket,
    FROM 
        questions_ordered
)
SELECT
    questions_experience_bucket,
    COUNT(*) AS total_questions,
    SAFE_DIVIDE(
        COUNTIF(answer_count > 0), 
        COUNT(*)
    ) AS answer_rate,
    SAFE_DIVIDE(
        COUNTIF(has_accepted_answer), 
        COUNT(*)
    ) AS accepted_answer_rate
FROM 
    with_buckets
GROUP BY 
    questions_experience_bucket
HAVING 
    total_questions >= 1000
ORDER BY 
    accepted_answer_rate DESC

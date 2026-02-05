-- -----------------------------------------------------------------------------
-- Query 3C: Length of Code Snippets
-- -----------------------------------------------------------------------------
WITH 
question_analysis AS (
    SELECT
        id AS question_id,
        answer_count,
        accepted_answer_id IS NOT NULL AS has_accepted_answer,
        LENGTH(body) AS body_length,
        COALESCE(SUM(LENGTH(code)), 0) AS code_char_length
    FROM 
        `bigquery-public-data.stackoverflow.posts_questions`
    LEFT JOIN 
        UNNEST(REGEXP_EXTRACT_ALL(body, r'<code>(.*?)</code>')) AS code
    WHERE
        creation_date >= '2013-01-01'
    GROUP BY
        question_id,
        answer_count,
        has_accepted_answer,
        body_length
),
with_percentages AS (
    SELECT
        question_id,
        answer_count,
        has_accepted_answer,
        body_length,
        code_char_length,
        SAFE_DIVIDE(
            code_char_length,
            body_length
        ) AS code_percentage
    FROM 
        question_analysis
),
bucketed AS (
    SELECT
        question_id,
        answer_count,
        has_accepted_answer,
        body_length,
        code_char_length,
        code_percentage,
        CASE
            WHEN code_percentage = 0 THEN '0. No code (0%)'
            WHEN code_percentage < 0.01 THEN '1. Minimal (<1%)'
            WHEN code_percentage < 0.05 THEN '2. Low (1-5%)'
            WHEN code_percentage < 0.10 THEN '3. Moderate (5-10%)'
            WHEN code_percentage < 0.20 THEN '4. Significant (10-20%)'
            WHEN code_percentage < 0.40 THEN '5. High (20-40%)'
            WHEN code_percentage < 0.60 THEN '6. Very High (40-60%)'
            ELSE '7. Mostly Code (60%+)'
        END AS code_pct_bucket
    FROM
        with_percentages
)
SELECT
    code_pct_bucket,
    COUNT(*) AS total_questions,
    AVG(code_percentage) AS avg_code_pct,
    AVG(body_length) AS avg_body_length,
    AVG(code_char_length) AS avg_code_chars,
    SAFE_DIVIDE(
        COUNTIF(answer_count > 0), 
        COUNT(*)
    ) AS answer_rate,
    SAFE_DIVIDE(
        COUNTIF(has_accepted_answer), 
        COUNT(*)
    ) AS accepted_answer_rate,
    AVG(answer_count) AS avg_answers_per_question
FROM 
    bucketed
GROUP BY 
    code_pct_bucket
ORDER BY 
    accepted_answer_rate DESC

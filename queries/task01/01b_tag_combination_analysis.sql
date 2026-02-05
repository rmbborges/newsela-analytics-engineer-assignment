-- -----------------------------------------------------------------------------
-- Query 1B: Tag Combinations
-- -----------------------------------------------------------------------------
WITH 
RECURSIVE question_stats AS (
    SELECT
        id AS question_id,
        SPLIT(tags, "|") AS tags,
        answer_count,
        accepted_answer_id IS NOT NULL AS has_accepted_answer
    FROM 
        `bigquery-public-data.stackoverflow.posts_questions`
    WHERE 
        EXTRACT(YEAR FROM creation_date) = 2022
        AND ARRAY_LENGTH(SPLIT(tags, "|")) > 1
  ),
  indexed_tags AS (
    SELECT
        question_id,
        answer_count,
        has_accepted_answer,
        LOWER(TRIM(tag)) AS tag,
        tag_id
    FROM
        question_stats
    LEFT JOIN
        UNNEST(tags) AS tag WITH OFFSET tag_id
  ),
  combinations AS (
    SELECT
        question_id,
        answer_count,
        has_accepted_answer,
        [tag] AS tag_combo,
        tag_id AS max_tag_id
    FROM
        indexed_tags

    UNION ALL

    SELECT
        combinations.question_id,
        combinations.answer_count,
        combinations.has_accepted_answer,
        ARRAY_CONCAT(combinations.tag_combo, [indexed_tags.tag]) AS tag_combo,
        indexed_tags.tag_id AS max_tag_id
    FROM
        combinations
    JOIN
        indexed_tags
        ON combinations.question_id = indexed_tags.question_id
        AND indexed_tags.tag_id > combinations.max_tag_id
    -- Stop rule: avoid too many iterations
    WHERE
        ARRAY_LENGTH(combinations.tag_combo) < 4
  ),
  aggregated AS (
    SELECT
        tag_combo,
        ARRAY_LENGTH(tag_combo) AS combo_size,
        COUNT(DISTINCT(question_id)) AS total_questions_count,
        SUM(answer_count) AS total_answers_count,
        COUNTIF(has_accepted_answer) / COUNT(DISTINCT(question_id)) AS approved_answers_rate
    FROM
        combinations
    GROUP BY
        tag_combo,
        combo_size
)
SELECT
    tag_combo,
    combo_size,
    total_questions_count,
    total_answers_count,
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
    combo_size > 1
    AND total_answers_count >= 1000
ORDER BY
    rank_total_answers_count
/**
CHALLENGE 1
**/
-- STEP 1
SELECT t.title_id, a.au_id, (t.advance * ta.royaltyper / 100) AS advance
    , (t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS sales_royalty
FROM Authors a
    INNER JOIN titleauthor ta ON a.au_id = ta.au_id
    INNER JOIN titles t ON ta.title_id = t.title_id
    INNER JOIN sales s ON t.title_id = s.title_id
;

-- STEP 2
SELECT t1.title_id, t1.au_id, SUM(t1.sales_royalty) as royalties
FROM
    (SELECT t.title_id, a.au_id, (t.advance * ta.royaltyper / 100) AS advance
        , (t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS sales_royalty
    FROM Authors a
        INNER JOIN titleauthor ta ON a.au_id = ta.au_id
        INNER JOIN titles t ON ta.title_id = t.title_id
        INNER JOIN sales s ON t.title_id = s.title_id) t1
GROUP BY t1.au_id, t1.title_id
;

-- STEP 3
SELECT t2.au_id, t2.title_id, (t2.royalties + t3.advance) as total_sales
FROM
    (SELECT t1.title_id, t1.au_id, SUM(t1.sales_royalty) as royalties
    FROM 
        (SELECT t.title_id, a.au_id, (t.advance * ta.royaltyper / 100) AS advance
            , (t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS sales_royalty
        FROM Authors a
            INNER JOIN titleauthor ta ON a.au_id = ta.au_id
            INNER JOIN titles t ON ta.title_id = t.title_id
            INNER JOIN sales s ON t.title_id = s.title_id) t1
    GROUP BY t1.au_id, t1.title_id) t2
    INNER JOIN 
        (SELECT t1.title_id, a1.au_id, (t1.advance * ta1.royaltyper / 100) AS advance
        FROM Authors a1
            INNER JOIN titleauthor ta1 ON a1.au_id = ta1.au_id
            INNER JOIN titles t1 ON ta1.title_id = t1.title_id
            INNER JOIN sales s1 ON t1.title_id = s1.title_id
        GROUP BY a1.au_id, t1.title_id) t3 ON t2.title_id = t3.title_id AND t2.au_id = t2.au_id
ORDER BY (t2.royalties + t3.advance) DESC
LIMIT 3
;

/**
CHALLENGE 2
**/
-- first table
CREATE TEMPORARY TABLE IF NOT EXISTS temp_t1 AS 
(SELECT t.title_id, a.au_id, (t.advance * ta.royaltyper / 100) AS advance
    , (t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS sales_royalty
FROM Authors a
    INNER JOIN titleauthor ta ON a.au_id = ta.au_id
    INNER JOIN titles t ON ta.title_id = t.title_id
    INNER JOIN sales s ON t.title_id = s.title_id)
;

CREATE TEMPORARY TABLE IF NOT EXISTS temp_t2 AS
(SELECT t1.title_id, t1.au_id, SUM(t1.sales_royalty) as royalties
FROM temp_t1  t1
GROUP BY t1.au_id, t1.title_id)
;

SELECT t2.au_id, t2.title_id, (t2.royalties + t3.advance) as total_sales
FROM temp_t2 t2
    INNER JOIN temp_t1 t1 ON t2.title_id = t1.title_id AND t2t.au_id = t1.au_id
ORDER BY (t2.royalties + t3.advance) DESC
LIMIT 3
;

/**
CHALLENGE 3
**/
CREATE TABLE IF NOT EXISTS most_profiting_authors
(SELECT t2.au_id, (t2.royalties + t3.advance) as total_sales
FROM temp_t2 t2
    INNER JOIN temp_t1 t1 ON t2.title_id = t1.title_id AND t2t.au_id = t1.au_id
ORDER BY (t2.royalties + t3.advance) DESC
LIMIT 2)
;
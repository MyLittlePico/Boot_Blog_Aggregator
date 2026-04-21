-- name: CreateUser :one
INSERT INTO users (id, created_at, updated_at, name)
VALUES (
    $1,
    $2,
    $3,
    $4
)
RETURNING *;

-- name: GetUser :one
SELECT * FROM users
WHERE name = $1;

-- name: GetFeed :one
SELECT * FROM feeds
WHERE url = $1;

-- name: Reset :exec
DELETE FROM users;

-- name: GetUsers :many
SELECT name FROM users;

-- name: CreateFeed :one
INSERT INTO feeds (id, created_at, updated_at, name, url, user_id)
VALUES (
    $1,
    $2,
    $3,
    $4,
    $5,
    $6
)
RETURNING *;

-- name: GetFeedsInfo :many
SELECT feeds.name, feeds.url, users.name AS user_name
FROM feeds
LEFT JOIN users ON users.id = feeds.user_id;


-- name: CreateFeedFollow :one
WITH inserted_feed_follow AS(
    INSERT INTO feed_follows(id, created_at, updated_at, user_id, feed_id)
    VALUES ($1,$2,$3,$4,$5)
    RETURNING *
)
SELECT 
    inserted_feed_follow.* ,
    feeds.name AS feed_name,
    users.name AS user_name
FROM inserted_feed_follow
INNER JOIN users ON inserted_feed_follow.user_id = users.id
INNER JOIN feeds ON inserted_feed_follow.feed_id = feeds.id;


-- name: GetFeedFollowsForUser :many
SELECT feed_follows.*, feeds.name AS feed_name, users.name AS user_name FROM feed_follows
JOIN users ON users.id = feed_follows.user_id
JOIN feeds ON feeds.id = feed_follows.feed_id

WHERE feed_follows.user_id = $1;


-- name: Unfollow :exec
DELETE FROM feed_follows
WHERE user_id = $1
AND feed_id = $2;

-- name: MarkFeedFetched :exec
UPDATE feeds
SET last_fetched_at = NOW(),
updated_at = NOW()
WHERE id = $1;

-- name: GetNextFeedToFetch :one
SELECT * FROM feeds
ORDER BY last_fetched_at ASC NULLS FIRST
LIMIT 1;

-- name: CreatePost :exec
INSERT INTO posts(id,created_at,updated_at,title,url,description,published_at,feed_id)
VALUES(
    $1,
    NOW(),
    NOW(),
    $2,
    $3,
    $4,
    $5,
    $6
);

-- name: GetPostsForUser :many
SELECT posts.* FROM posts
INNER JOIN feed_follows ON feed_follows.feed_id = posts.feed_id
WHERE feed_follows.user_id = $1

ORDER BY posts.published_at DESC
LIMIT $2;
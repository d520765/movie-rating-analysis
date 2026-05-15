-- делаем 4 аналитические витрины из основной таблицы clean.movie_base
-- marts.mart_movie_main = удобная таблица по фильмам
-- marts.mart_genre_stats = статистика по жанрам
-- marts.mart_year_stats = статистика по годам
-- marts.mart_director_stats = статистика по режиссёрам

--Витрины будем использовать на следующем этапе проекта
--в ноутбуке 04_analysis.ipynb для анализа признаков,
--связанных с высоким пользовательским рейтингом фильмов

 create schema if not exists marts;

-- mart_movie_main
drop table if exists marts.mart_movie_main;

create table marts.mart_movie_main as
select
    id_num,
    title,
    original_title,
    original_language,
    release_date,
    release_year,
    main_genre,
    director,

    runtime,
    budget,
    revenue,
    profit,
    roi,

    popularity,
    vote_average as tmdb_vote_average,
    vote_count as tmdb_vote_count,

    avg_rating as user_avg_rating,
    rating_count as user_rating_count,
    weighted_rating,
    high_rating_flag,

    has_budget,
    has_revenue,
    genre_count,
    cast_size,
    keyword_count
from clean.movie_base;



-- mart_genre_stats
drop table if exists marts.mart_genre_stats;

create table marts.mart_genre_stats as
select
    main_genre,

    -- считаем количество всех фильмов в каждом жанре
    COUNT(*) as movie_count,

    -- считаем количество фильмов, у которых есть weighted_rating
    COUNT(weighted_rating) as rated_movie_count,

    -- считаем средние значения по жанру
    -- avg_weighted_rating — средний взвешенный рейтинг
    -- avg_user_rating — средний пользовательский рейтинг
    -- avg_tmdb_vote_average — средний рейтинг TMDB
    ROUND(AVG(weighted_rating)::numeric, 3) as avg_weighted_rating,
    ROUND(AVG(avg_rating)::numeric, 3) as avg_user_rating,
    ROUND(AVG(vote_average)::numeric, 3) as avg_tmdb_vote_average,

    -- считаем долю высокорейтинговых фильмов внутри жанра
    ROUND(
        AVG(
            case 
                when weighted_rating is not null then high_rating_flag::numeric
                else null
            end
        ),
        3
    ) as high_rating_share,

    -- средняя длительность фильмов внутри жанра
    ROUND(AVG(runtime)::numeric, 1) as avg_runtime,

    -- средний бюджет и средняя выручка без нулевых значений
    -- 0 здесь часто означает не реальный ноль, а отсутствие данных
    ROUND(AVG(NULLIF(budget, 0))::numeric, 0) as avg_budget_nonzero,
    ROUND(AVG(NULLIF(revenue, 0))::numeric, 0) as avg_revenue_nonzero,

    -- средняя прибыль только для фильмов с известным бюджетом и выручкой
    ROUND(
        AVG(
            case 
                when has_budget = 1 and has_revenue = 1 then profit
                else null
            end
        )::numeric,
        0
    ) as avg_profit_known,

    -- общее количество пользовательских оценок
    -- если rating_count не пустой, берём rating_count
    -- если rating_count равен NULL, заменяем его на 0
    SUM(COALESCE(rating_count, 0)) as total_user_ratings

from clean.movie_base
where main_genre is not null 
  and main_genre <> ''
group by main_genre
having COUNT(weighted_rating) > 0
order by avg_weighted_rating desc;



--marts.mart_year_stats
--нужна, чтобы анализировать динамику:
--как менялся средний рейтинг фильмов по годам
--в какие годы выходило больше фильмов
--как менялась доля high rating
--как менялись бюджеты и выручка
--сколько пользовательских оценок приходится на разные годы
drop table if exists marts.mart_year_stats;

create table marts.mart_year_stats as
select release_year,
	COUNT(*) as movie_count,
	COUNT(weighted_rating) as rated_movie_count,

	ROUND(AVG(weighted_rating)::numeric, 3) as avg_weighted_rating,
    ROUND(AVG(avg_rating)::numeric, 3) as avg_user_rating,
    ROUND(AVG(vote_average)::numeric, 3) as avg_tmdb_vote_average,
    
        ROUND(
        AVG(
            case 
                when weighted_rating is not null then high_rating_flag::numeric
                else null 
            end
        ), 
        3
    ) as high_rating_share,

    ROUND(AVG(runtime)::numeric, 1) as avg_runtime,
    ROUND(AVG(NULLIF(budget, 0))::numeric, 0) as avg_budget_nonzero,
    ROUND(AVG(NULLIF(revenue, 0))::numeric, 0) as avg_revenue_nonzero,

    SUM(COALESCE(rating_count, 0)) as total_user_ratings
    
from clean.movie_base
where release_year is not null
group by release_year
having COUNT(weighted_rating) > 0
order by release_year;



--mart_director_stats
--у каких режиссёров выше средний weighted_rating
--у кого больше фильмов в датасете
--у кого выше доля high rating
--сколько пользовательских оценок получили фильмы режиссёра

--!!!!! Оставить только тех режиссёров, у которых есть минимум 3 фильма с рейтингом.
--если у режиссёра только один фильм, и он получил высокий рейтинг, он сразу попадёт в топ. Но это может быть случайность

drop table if exists marts.mart_director_stats;

create table marts.mart_director_stats as
select
    director,

    COUNT(*) as movie_count,

    COUNT(weighted_rating) as rated_movie_count,

    ROUND(AVG(weighted_rating)::numeric, 3) as avg_weighted_rating,
    ROUND(AVG(avg_rating)::numeric, 3) as avg_user_rating,
    ROUND(AVG(vote_average)::numeric, 3) as avg_tmdb_vote_average,

    ROUND(
        AVG(
            case 
                when weighted_rating is not null then high_rating_flag::numeric
                else null 
            end
        ), 
        3
    ) as high_rating_share,

    ROUND(AVG(runtime)::numeric, 1) as avg_runtime,

    ROUND(AVG(NULLIF(budget, 0))::numeric, 0) as avg_budget_nonzero,
    ROUND(AVG(NULLIF(revenue, 0))::numeric, 0) as avg_revenue_nonzero,

    SUM(COALESCE(rating_count, 0)) as total_user_ratings

from clean.movie_base
where director is not null and director <> ''
group by director
having COUNT(weighted_rating) >= 3
order by avg_weighted_rating desc;

select 'mart_movie_main' as table_name, count(*) as row_count
from marts.mart_movie_main

union all

select 'mart_genre_stats' as table_name, count(*) as row_count
from marts.mart_genre_stats

union all

select 'mart_year_stats' as table_name, count(*) as row_count
from marts.mart_year_stats

union all

select 'mart_director_stats' as table_name, count(*) as row_count
from marts.mart_director_stats;
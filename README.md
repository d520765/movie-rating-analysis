# Movie Rating Analysis

End-to-end data analytics project based on The Movies Dataset.  
The goal of the project is to analyze which movie characteristics are associated with higher user ratings and build a complete analytics pipeline from data cleaning to SQL marts and Power BI dashboard.

## Project Goal

**What factors are associated with a high movie rating?**

The analysis focuses on:

- genres;
- release years and decades;
- directors;
- user ratings;
- number of ratings;
- budget, revenue, profit and ROI;
- movie popularity.

## Tools

- Python
- pandas
- numpy
- matplotlib
- PostgreSQL
- SQL
- DBeaver
- Power BI
- Jupyter Notebook



## Workflow

### 1. Data Audit

The raw datasets were reviewed in Python.  
At this stage, I checked table sizes, column types, missing values, duplicates and general data quality issues.

Notebook:

```text
notebook/01_data_audit.ipynb
```

### 2. Data Cleaning

The data was cleaned and prepared for analysis.  
I processed movie IDs, dates, genres, financial columns, ratings and director information.

The main prepared table was:

```text
movie_base
```

Notebook:

```text
notebook/02_cleaning.ipynb
```

### 3. PostgreSQL Load

Cleaned tables were loaded into PostgreSQL into the `clean` schema.

Main tables:

```text
clean.movies_clean
clean.credits_clean
clean.keywords_clean
clean.ratings_summary
clean.links_clean
clean.movie_base
```

Notebook:

```text
notebook/03_postgres_load.ipynb
```

### 4. SQL Marts

Analytical marts were created in PostgreSQL in the `marts` schema.

Created marts:

```text
marts.mart_movie_main
marts.mart_genre_stats
marts.mart_year_stats
marts.mart_director_stats
```

SQL script:

```text
sql/create_marts_postgres.sql
```

### 5. Python Analysis

The SQL marts were analyzed in Python.  
The analysis compared high-rated and non-high-rated movies by genre, decade, director, popularity and financial indicators.

Notebook:

```text
notebook/04_analysis.ipynb
```

Main output tables are stored in:

```text
outputs/day4_analysis/
```

### 6. Power BI Dashboard

The final dashboard was created in Power BI.

Dashboard pages:

- **Overview** — general movie rating overview and key metrics;
- **Rating Factors** — genres, decades, directors, correlations and top movies.

Power BI file:

```text
dashboard/movie_rating_dashboard.pbix
```

## Key Results

Main findings:

- some genres have a higher share of high-rated movies;
- financial success does not automatically mean a higher user rating;
- director analysis requires filtering to avoid random one-movie cases;
- rating patterns differ by decade;
- number of user ratings is important for reliable comparison.

## How to Run

Clone the repository:

```bash
git clone https://github.com/d520765/movie-rating-analysis.git
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Run notebooks in order:

```text
01_data_audit.ipynb
02_cleaning.ipynb
03_postgres_load.ipynb
04_analysis.ipynb
```

The PostgreSQL connection parameters should be stored locally in `.env`.

Example:

```text
POSTGRES_USER=your_user
POSTGRES_PASSWORD=your_password
POSTGRES_HOST=your_host
POSTGRES_PORT=5432
POSTGRES_DB=movies_project
```

The `.env` file is not included in the repository.

## Conclusion

This project demonstrates a complete analytics workflow:

- data cleaning in Python;
- PostgreSQL database loading;
- SQL mart creation;
- analytical exploration;
- Power BI dashboarding.
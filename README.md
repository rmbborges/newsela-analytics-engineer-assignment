# Stack Overflow Post Analysis

> Senior Analytics Engineering Take-Home Challenge

This repository contains SQL queries and analysis for the Stack Overflow public BigQuery dataset, exploring factors that influence question success rates.

## Table of Contents

- [Stack Overflow Post Analysis](#stack-overflow-post-analysis)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
    - [Dataset](#dataset)
  - [Task 1: Tag Analysis](#task-1-tag-analysis)
    - [Query: Single Tag Analysis](#query-single-tag-analysis)
    - [Results](#results)
    - [Findings](#findings)
    - [Query: Tag Combination Analysis](#query-tag-combination-analysis)
    - [Results](#results-1)
    - [Findings](#findings-1)
  - [Task 2: `Python` vs `dbt` YoY Analysis](#task-2-python-vs-dbt-yoy-analysis)
    - [Query: Python vs dbt YoY Analysis](#query-python-vs-dbt-yoy-analysis)
    - [Results](#results-2)
    - [Findings](#findings-2)
  - [Task 3: Factors Beyond Tags](#task-3-factors-beyond-tags)
    - [Query: Reputation](#query-reputation)
    - [Results](#results-3)
    - [Findings](#findings-3)
    - [Query: Veterancy](#query-veterancy)
    - [Results](#results-4)
    - [Findings](#findings-4)
    - [Query: Length of code snippets](#query-length-of-code-snippets)
    - [Findings](#findings-5)
    - [Query: Title and Length of code snippets](#query-title-and-length-of-code-snippets)
    - [Findings](#findings-6)
    - [Query: Veterancy and questions best-practices](#query-veterancy-and-questions-best-practices)
    - [Findings](#findings-7)

---

## Overview

This analysis explores the `bigquery-public-data.stackoverflow` dataset to answer three key questions:

1. **Tag Analysis**: Which tags lead to the most answers and highest acceptance rates?
2. **Python vs dbt**: How do these technologies compare over the last 10 years?
3. **Creative Analysis**: What factors beyond tags correlate with question success?

### Dataset

All queries use the public BigQuery dataset:
```
bigquery-public-data.stackoverflow.posts_questions
bigquery-public-data.stackoverflow.users
```

---

## Task 1: Tag Analysis

> What tags on a Stack Overflow question lead to the most answers and the highest rate of approved answers for the current year? What tags lead to the least? How about combinations of tags?

### Query: [Single Tag Analysis](queries/task01/01a_single_tag_analysis.sql#L7)

- **Performance consideration:** 
  - Since there's no partitioning column in this public dataset table, the main way to reduce costs is to avoid querying unnecessary columns.
  - We should also avoid `COUNT DISTINCT` when possible. It's fine here because we're dealing with a manageable number of records, but for larger datasets it can cause performance issues. If that happens and we can tolerate some accuracy loss, `APPROX_COUNT_DISTINCT` is a good alternative. It's a statistical estimate that gets pretty close to the exact count.

  <ul>
    <details>
      <summary>Query we can use to check the partitioned column for <code>posts_questions</code> table in BigQuery.</summary>

    ```sql
    SELECT
        column_name
    FROM 
        `bigquery-public-data.stackoverflow.INFORMATION_SCHEMA.COLUMNS`
    WHERE 
        table_name = 'posts_questions' 
        AND is_partitioning_column = 'YES'
    ```

    </details>
  </ul>

- Assumptions:
  - **Current year:** The "current year" for this assignment is `2022` (the most recent event in this table is from `2022-09-25 05:56:32.863000 UTC`), so I ran the analysis on posts from that year.

  <ul>
    <details>
      <summary>Query used to check the most recent creation timestamp in <code>posts_questions</code>.</summary>
          
    ```sql
    SELECT 
        MAX(creation_date) 
    FROM 
        `bigquery-public-data.stackoverflow.posts_questions`;
    ```

    </details>
  </ul>

  - **Irrelevant data**: To filter out low-volume tags, we set a threshold of `1000` questions.

### Results

<details>
  <summary>
    <b>Table A: Top 20 single tags by number of questions</b>
  </summary>

| tag         | total_questions_count | total_answers_count | accepted_anwer_count | approved_answers_rate   | rank_total_answers_count | rank_approved_answers_rate |
|-------------|----------------------|---------------------|----------------------|-------------------------|-------------------------|---------------------------|
| python      | 202689               | 189565              | 70899                | 0.3498                  | 1                       | 134                       |
| javascript  | 139880               | 130590              | 46490                | 0.3324                  | 2                       | 158                       |
| reactjs     | 75674                | 64493               | 22159                | 0.2928                  | 3                       | 228                       |
| html        | 50524                | 51189               | 17178                | 0.3400                  | 4                       | 143                       |
| java        | 65190                | 50897               | 17530                | 0.2689                  | 5                       | 281                       |
| c#          | 54166                | 45908               | 17617                | 0.3252                  | 6                       | 170                       |
| pandas      | 35684                | 41921               | 17760                | 0.4977                  | 7                       | 21                        |
| r           | 39675                | 40455               | 17826                | 0.4493                  | 8                       | 39                        |
| css         | 35408                | 37915               | 12545                | 0.3543                  | 9                       | 124                       |
| sql         | 30953                | 34074               | 12464                | 0.4027                  | 10                      | 73                        |
| flutter     | 35566                | 33633               | 10547                | 0.2965                  | 11                      | 219                       |
| android     | 43937                | 28761               | 9716                 | 0.2211                  | 12                      | 382                       |
| node.js     | 40314                | 28274               | 10115                | 0.2509                  | 13                      | 326                       |
| arrays      | 21168                | 28216               | 9797                 | 0.4628                  | 14                      | 35                        |
| c++         | 32000                | 28103               | 11462                | 0.3582                  | 15                      | 121                       |
| php         | 34346                | 26226               | 9233                 | 0.2688                  | 16                      | 283                       |
| typescript  | 30201                | 26037               | 10814                | 0.3581                  | 17                      | 122                       |
| dataframe   | 20746                | 25808               | 10848                | 0.5229                  | 18                      | 13                        |
| python-3.x  | 27864                | 25032               | 9706                 | 0.3483                  | 19                      | 135                       |
| dart        | 17201                | 17945               | 6094                 | 0.3543                  | 20                      | 125                       |

</details>
<br>
<details>
  <summary>
    <b>Table B: Top 20 single tags by approved answers rate</b>
  </summary>

| tag                      | total_questions_count | total_answers_count | accepted_anwer_count | approved_answers_rate | rank_total_answers_count | rank_approved_answers_rate |
|--------------------------|----------------------|---------------------|----------------------|----------------------|-------------------------|---------------------------|
| awk                      | 1266                 | 3107                | 836                  | 0.6603               | 118                     | 1                         |
| dplyr                    | 4093                 | 6115                | 2626                 | 0.6416               | 67                      | 2                         |
| sed                      | 1085                 | 2376                | 671                  | 0.6184               | 151                     | 3                         |
| tidyverse                | 1409                 | 1929                | 869                  | 0.6167               | 192                     | 4                         |
| regex                    | 7394                 | 10218               | 4325                 | 0.5849               | 40                      | 5                         |
| beautifulsoup            | 2611                 | 3331                | 1459                 | 0.5588               | 107                     | 6                         |
| group-by                 | 1944                 | 2346                | 1078                 | 0.5545               | 155                     | 7                         |
| julia                    | 1211                 | 1439                | 670                  | 0.5533               | 253                     | 8                         |
| haskell                  | 1467                 | 1656                | 809                  | 0.5515               | 225                     | 9                         |
| c++20                    | 1055                 | 1134                | 578                  | 0.5479               | 316                     | 10                        |
| google-sheets-formula    | 1735                 | 2078                | 939                  | 0.5412               | 178                     | 11                        |
| aggregation-framework    | 1023                 | 945                 | 535                  | 0.5230               | 360                     | 12                        |
| dataframe                | 20746                | 25808               | 10848                | 0.5229               | 18                      | 13                        |
| replace                  | 1317                 | 1792                | 688                  | 0.5224               | 204                     | 14                        |
| ggplot2                  | 4958                 | 4811                | 2586                 | 0.5216               | 84                      | 15                        |
| rust                     | 5778                 | 5616                | 2979                 | 0.5156               | 74                      | 16                        |
| count                    | 1079                 | 1363                | 554                  | 0.5134               | 267                     | 17                        |
| split                    | 1304                 | 1953                | 666                  | 0.5107               | 189                     | 18                        |
| dictionary               | 5922                 | 8237                | 3019                 | 0.5098               | 50                      | 19                        |
| list                     | 10067                | 15300               | 5016                 | 0.4983               | 26                      | 20                        |

</details>
<br>
<details>
  <summary>
    <b>Table C: Bottom 20 single tags by approved answers rate</b>
  </summary>

| tag                      | total_questions_count | total_answers_count | accepted_anwer_count | approved_answers_rate | rank_total_answers_count | rank_approved_answers_rate |
|--------------------------|----------------------|---------------------|----------------------|----------------------|-------------------------|---------------------------|
| google-chrome-extension  | 2032                 | 742                 | 262                  | 0.1289               | 403                     | 469                       |
| browser                  | 1209                 | 564                 | 156                  | 0.1290               | 434                     | 468                       |
| sharepoint               | 1279                 | 586                 | 177                  | 0.1384               | 431                     | 467                       |
| proxy                    | 1206                 | 469                 | 168                  | 0.1393               | 439                     | 466                       |
| google-chrome            | 3204                 | 1546                | 469                  | 0.1464               | 241                     | 465                       |
| iframe                   | 1335                 | 643                 | 197                  | 0.1476               | 422                     | 464                       |
| installation             | 1255                 | 759                 | 188                  | 0.1498               | 399                     | 463                       |
| plugins                  | 1176                 | 540                 | 178                  | 0.1514               | 437                     | 462                       |
| audio                    | 1631                 | 786                 | 254                  | 0.1557               | 395                     | 461                       |
| firebase-cloud-messaging | 1095                 | 609                 | 173                  | 0.1580               | 427                     | 460                       |
| angularjs                | 1184                 | 669                 | 191                  | 0.1613               | 416                     | 459                       |
| session                  | 1002                 | 497                 | 162                  | 0.1617               | 438                     | 458                       |
| websocket                | 2553                 | 1123                | 413                  | 0.1618               | 319                     | 457                       |
| server                   | 1940                 | 988                 | 314                  | 0.1619               | 346                     | 456                       |
| webpack                  | 3564                 | 1725                | 580                  | 0.1627               | 219                     | 455                       |
| ssl                      | 2580                 | 1220                | 422                  | 0.1636               | 296                     | 454                       |
| tomcat                   | 1123                 | 551                 | 184                  | 0.1638               | 435                     | 453                       |
| deployment               | 1526                 | 886                 | 254                  | 0.1664               | 371                     | 452                       |
| eclipse                  | 1698                 | 822                 | 284                  | 0.1673               | 383                     | 451                       |
| raspberry-pi             | 1344                 | 667                 | 225                  | 0.1674               | 417                     | 450                       |

</details>

### Findings
- Niche tools like `awk` (66%), `dplyr` (64%), and `sed` (62%) achieve the highest acceptance rates;
- Tags like `pandas` (50%), `dataframe` (52%), and `arrays` (46%) appear in both top volume and top acceptance rankings.

### Query: [Tag Combination Analysis](queries/task01/01b_tag_combination_analysis.sql#L7)

- **Performance consideration:** 
  - For this solution, I used a [recursive CTE](https://docs.cloud.google.com/bigquery/docs/recursive-ctes) to generate tag combinations. This approach works here because we have low data volume and a clear stop condition. By default, BigQuery caps recursive iterations at 500 due to the heavy computation involved, but since the most tags on any question in our dataset is 5, we'll never exceed 4 distinct tags per combination.

### Results


<details>
  <summary>
    <b>Table D: Top 20 tag combinations by total answers count</b>
  </summary>

| tag_combo                      | combo_size | total_questions_count | total_answers_count | approved_answers_rate | rank_total_answers_count | rank_approved_answers_rate |
|--------------------------------|------------|----------------|--------------------|----------------------|-------------------------|---------------------------|
| [python,pandas]                | 2          | 30987          | 37399              | 0.5070               | 1                       | 4094                      |
| [javascript,reactjs]           | 2          | 31341          | 30336              | 0.3312               | 2                       | 11378                     |
| [html,css]                     | 2          | 23125          | 27024              | 0.3764               | 3                       | 9065                      |
| [javascript,html]              | 2          | 23479          | 23698              | 0.3432               | 4                       | 10850                     |
| [python,dataframe]             | 2          | 14562          | 18239              | 0.5281               | 5                       | 3533                      |
| [pandas,dataframe]             | 2          | 14238          | 18059              | 0.5409               | 6                       | 3209                      |
| [flutter,dart]                 | 2          | 16144          | 16965              | 0.3495               | 7                       | 10503                     |
| [python,python-3.x]            | 2          | 15488          | 16526              | 0.3928               | 8                       | 8271                      |
| [python,pandas,dataframe]      | 3          | 12429          | 16212              | 0.5506               | 9                       | 2981                      |
| [javascript,css]               | 2          | 11686          | 12248              | 0.3521               | 10                      | 10347                     |
| [javascript,node.js]           | 2          | 14816          | 12126              | 0.2966               | 11                      | 13501                     |
| [javascript,arrays]            | 2          | 7285           | 11592              | 0.5002               | 12                      | 4143                      |
| [python,list]                  | 2          | 6336           | 10723              | 0.5120               | 13                      | 3982                      |
| [python,numpy]                 | 2          | 8486           | 9540               | 0.4631               | 14                      | 5351                      |
| [javascript,html,css]          | 3          | 8509           | 9446               | 0.3634               | 15                      | 9737                      |
| [python,django]                | 2          | 11239          | 9162               | 0.3201               | 16                      | 12019                     |
| [javascript,typescript]        | 2          | 8542           | 8298               | 0.3727               | 17                      | 9218                      |
| [javascript,jquery]            | 2          | 9031           | 8184               | 0.3436               | 18                      | 10836                     |
| [android,kotlin]               | 2          | 9286           | 7622               | 0.3192               | 19                      | 12092                     |
| [java,spring-boot]             | 2          | 9278           | 7192               | 0.2543               | 20                      | 16242                     |

</details>
<br>
<details>
  <summary>
    <b>Table E: Top 20 tag combinations by approved answers rate</b>
  </summary>

| tag_combo                 | combo_size | total_questions_count | total_answers_count | approved_answers_rate | rank_total_answers_count | rank_approved_answers_rate |
|---------------------------|------------|----------------|--------------------|----------------------|-------------------------|---------------------------|
| [r,dataframe,dplyr]       | 3          | 632            | 1091               | 0.7342               | 283                     | 1                         |
| [dataframe,dplyr]         | 2          | 645            | 1103               | 0.7271               | 278                     | 2                         |
| [r,data.table]            | 2          | 680            | 1051               | 0.6721               | 294                     | 3                         |
| [awk,sed]                 | 2          | 375            | 1096               | 0.6667               | 281                     | 4                         |
| [bash,awk]                | 2          | 514            | 1329               | 0.6595               | 222                     | 5                         |
| [pandas,pandas-groupby]   | 2          | 893            | 1164               | 0.6484               | 258                     | 6                         |
| [r,dplyr]                 | 2          | 3963           | 5995               | 0.6472               | 28                      | 7                         |
| [bash,sed]                | 2          | 503            | 1168               | 0.6402               | 256                     | 8                         |
| [python,pandas-groupby]   | 2          | 794            | 1034               | 0.6398               | 298                     | 9                         |
| [python,regex]            | 2          | 1691           | 2541               | 0.6286               | 86                      | 10                        |
| [python,python-3.x,pandas,dataframe] | 4 | 913         | 1319               | 0.6232               | 225                     | 11                        |
| [r,tidyverse]             | 2          | 1348           | 1889               | 0.6231               | 127                     | 12                        |
| [java,java-stream]        | 2          | 754            | 1332               | 0.6127               | 221                     | 13                        |
| [python,python-3.x,dataframe] | 3     | 1045           | 1476               | 0.6067               | 192                     | 14                        |
| [python-3.x,pandas,dataframe] | 3     | 1549           | 2023               | 0.5933               | 117                     | 15                        |
| [javascript,regex]        | 2          | 1094           | 1538               | 0.5868               | 183                     | 16                        |
| [r,dataframe]             | 2          | 3328           | 4933               | 0.5856               | 34                      | 17                        |
| [python,web-scraping,beautifulsoup] | 3 | 1285        | 1706               | 0.5790               | 155                     | 18                        |
| [python,pandas,dataframe,numpy] | 4  | 771            | 1061               | 0.5785               | 290                     | 19                        |
| [python,python-3.x,pandas] | 3       | 1637           | 2200               | 0.5761               | 99                      | 20                        |

</details>
<br>
<details>
  <summary>
    <b>Table F: Bottom 20 tag combinations by approved answers rate</b>
  </summary>

| tag_combo                  | combo_size | total_questions_count | total_answers_count | approved_answers_rate | rank_total_answers_count | rank_approved_answers_rate |
|----------------------------|------------|----------------|--------------------|----------------------|-------------------------|---------------------------|
| [android,react-native]     | 2          | 2274           | 1248               | 0.1513               | 240                     | 335                       |
| [java,android-studio]      | 2          | 2338           | 1549               | 0.1818               | 182                     | 334                       |
| [node.js,npm]              | 2          | 2591           | 1911               | 0.1822               | 126                     | 333                       |
| [android,ios]              | 2          | 1596           | 1106               | 0.1867               | 277                     | 332                       |
| [react-native,expo]        | 2          | 2592           | 1599               | 0.1960               | 172                     | 331                       |
| [android,gradle]           | 2          | 1528           | 1015               | 0.1983               | 305                     | 330                       |
| [ios,flutter]              | 2          | 1745           | 1411               | 0.2034               | 203                     | 329                       |
| [java,android,android-studio] | 3       | 1625           | 1234               | 0.2105               | 242                     | 328                       |
| [wordpress,woocommerce]    | 2          | 2455           | 1311               | 0.2151               | 228                     | 327                       |
| [python,jupyter-notebook]  | 2          | 2170           | 1476               | 0.2152               | 192                     | 326                       |
| [java,maven]               | 2          | 2349           | 1509               | 0.2180               | 188                     | 325                       |
| [android,android-studio]   | 2          | 5069           | 3776               | 0.2192               | 51                      | 324                       |
| [flutter,flutter-dependencies] | 2      | 1491           | 1370               | 0.2200               | 210                     | 323                       |
| [node.js,reactjs]          | 2          | 4794           | 3621               | 0.2230               | 56                      | 322                       |
| [php,wordpress]            | 2          | 4171           | 2557               | 0.2237               | 85                      | 321                       |
| [reactjs,express]          | 2          | 1420           | 1001               | 0.2254               | 310                     | 320                       |
| [android,flutter]          | 2          | 4260           | 3555               | 0.2277               | 59                      | 319                       |
| [python,pip]               | 2          | 1780           | 1356               | 0.2303               | 217                     | 318                       |
| [java,android]             | 2          | 8761           | 5941               | 0.2315               | 29                      | 317                       |
| [python,flask]             | 2          | 3707           | 2396               | 0.2317               | 92                      | 316                       |

</details>

### Findings

- The `[python, pandas]` combination leads with 37K answers and 51% acceptance rate. Adding `dataframe` to form `[python, pandas, dataframe]` further increases acceptance to 55%;
- R-related combinations like `[r, dataframe, dplyr]` (73%) and `[dataframe, dplyr]` (73%) achieve the highest acceptance rates across all tag combinations, outperforming even single specialized tags.

---

## Task 2: `Python` vs `dbt` YoY Analysis

> For posts tagged with only 'python' or 'dbt', what is the year over year change of question-to-answer ratio for the last 10 years? How about the rate of approved answers?

### Query: [Python vs dbt YoY Analysis](queries/task02/02_python_dbt_yoy.sql)

- **Performance consideration:** 
  - The query uses window functions (`LAG`) for YoY calculations which are quite efficient in BigQuery.

- **Assumptions:**
  - **Single-tag posts only**: The query filters for posts where the entire `tags` field equals exactly `'dbt'` or `'python'`. This excludes posts like `'python|pandas'` to ensure a fair comparison between the two technologies in isolation;
  - **Data availability**: The `dbt` tag only appears from 2020 onwards, while `python` has data going back to 2012 in this dataset.

### Results

<details>
  <summary>
    <b>Table G: Year-over-Year (YoY) Question/Answer Trends for <code>python</code> vs <code>dbt</code> Tags</b>
  </summary>

| creation_year | tag    | total_questions | total_questions_to_answer | total_approved_answer | questions_to_answer_rate | approved_answers_rate | question_to_answer_rate_yoy_change | approved_answers_rate_yoy_change |
|--------------:|--------|----------------:|--------------------------:|----------------------:|-------------------------:|----------------------:|------------------------------------:|---------------------------------:|
| 2012          | python |           5749  |                        62 |                 4144  |         0.0108          |         0.7208        |                                   |                                |
| 2013          | python |           7819  |                       218 |                 5096  |         0.0279          |         0.6517        |                 1.5853              |           -0.0958               |
| 2014          | python |           8537  |                       373 |                 5247  |         0.0437          |         0.6146        |                 0.5671              |           -0.0570               |
| 2015          | python |           9781  |                       614 |                 5565  |         0.0628          |         0.5690        |                 0.4368              |           -0.0743               |
| 2016          | python |          10344  |                       849 |                 5433  |         0.0821          |         0.5252        |                 0.3075              |           -0.0769               |
| 2017          | python |          11683  |                      1291 |                 5740  |         0.1105          |         0.4913        |                 0.3463              |           -0.0646               |
| 2018          | python |          11614  |                      1254 |                 5714  |         0.1080          |         0.4920        |                -0.0229              |            0.0014               |
| 2019          | python |          14503  |                      1520 |                 7079  |         0.1048          |         0.4881        |                -0.0293              |           -0.0079               |
| 2020          | python |          16256  |                      1945 |                 7396  |         0.1196          |         0.4550        |                 0.1416              |           -0.0679               |
| 2020          | dbt    |             31  |                         2 |                   13  |         0.0645          |         0.4194        |                                   |                                |
| 2021          | python |          15811  |                      2408 |                 6801  |         0.1523          |         0.4301        |                 0.2729              |           -0.0546               |
| 2021          | dbt    |             58  |                         9 |                   15  |         0.1552          |         0.2586        |                 1.4052              |           -0.3833               |
| 2022          | python |          12809  |                      3388 |                 4535  |         0.2645          |         0.3540        |                 0.7367              |           -0.1769               |
| 2022          | dbt    |             79  |                        12 |                   22  |         0.1519          |         0.2785        |                -0.0211              |            0.0768               |

</details>


### Findings
- Python peaked at 16K questions in 2020, then dropped 21% by 2022. Acceptance rate fell from 72% (2012) to 35% (2022), suggesting increased question complexity or community fatigue;
- dbt is still a small ecosystem. The acceptance rate dropped sharply from 42% to 26% in 2021, but the amount of records is not comparable with Python tag itself;
- Python's unanswered rate jumped from 1% to 26% over the decade. This suggests the community is struggling to keep up with question volume.

---

## Task 3: Factors Beyond Tags

> Other than tags, what qualities on a post correlate with the highest rate of answer and approved answer?

### Query: [Reputation](queries/task03/03a_reputation.sql)

- Assumptions:
  - My first hypothesis was that users with higher reputation (more about this [here](https://internal.stackoverflow.help/en/articles/8775594-reputation-and-voting)) create better questions.
  - I set the start date of the analysis to `2013` to cover ten years of data.

### Results

<details>
  <summary>
    <b>Table H: Answer and Acceptance Rates by Account Age & Reputation (<code>03a_veterancy.sql</code>)</b>
  </summary>

| account_age_bucket     | reputation_bucket         | total_questions | answer_rate | accepted_answer_rate |
|-----------------------|--------------------------|----------------:|------------:|---------------------:|
| 2. First week         | 6. Expert (5K+)          |           3013  |     0.9396  |            0.7610   |
| 3. First month        | 6. Expert (5K+)          |          10047  |     0.9373  |            0.7360   |
| 1. First day          | 6. Expert (5K+)          |           3249  |     0.9264  |            0.7341   |
| 4. First year         | 6. Expert (5K+)          |         158823  |     0.9291  |            0.7094   |
| 2. First week         | 5. Experienced (1K-5K)   |          19308  |     0.9171  |            0.6717   |
| 3. First month        | 5. Experienced (1K-5K)   |          56237  |     0.9144  |            0.6646   |
| 1. First day          | 5. Experienced (1K-5K)   |          24987  |     0.9118  |            0.6642   |
| 4. First year         | 5. Experienced (1K-5K)   |         581969  |     0.9036  |            0.6352   |
| 2. First week         | 4. Established (500-999) |          22187  |     0.9065  |            0.6291   |
| 1. First day          | 4. Established (500-999) |          33607  |     0.9057  |            0.6289   |
| 3. First month        | 4. Established (500-999) |          59928  |     0.9007  |            0.6241   |
| 5. Veteran (1+ year)  | 6. Expert (5K+)          |        1788917  |     0.8816  |            0.6014   |
| 4. First year         | 4. Established (500-999) |         456962  |     0.8861  |            0.5899   |
| 2. First week         | 3. Intermediate (100-499)|         102574  |     0.8930  |            0.5807   |
| 1. First day          | 3. Intermediate (100-499)|         186683  |     0.8970  |            0.5686   |
| 3. First month        | 3. Intermediate (100-499)|         238149  |     0.8862  |            0.5645   |
| 5. Veteran (1+ year)  | 5. Experienced (1K-5K)   |        2767964  |     0.8532  |            0.5520   |
| 4. First year         | 3. Intermediate (100-499)|        1225381  |     0.8678  |            0.5332   |
| 5. Veteran (1+ year)  | 4. Established (500-999) |        1361221  |     0.8357  |            0.5160   |
| 5. Veteran (1+ year)  | 3. Intermediate (100-499)|        2278206  |     0.8179  |            0.4728   |
| 2. First week         | 2. Beginner (10-99)      |         290286  |     0.8434  |            0.4413   |
| 3. First month        | 2. Beginner (10-99)      |         482683  |     0.8377  |            0.4341   |
| 4. First year         | 2. Beginner (10-99)      |        1629994  |     0.8176  |            0.4162   |
| 1. First day          | 2. Beginner (10-99)      |        1117836  |     0.8211  |            0.3972   |
| 5. Veteran (1+ year)  | 2. Beginner (10-99)      |        1896821  |     0.7723  |            0.3780   |
| 2. First week         | 1. New (< 10)            |         112648  |     0.7777  |            0.2646   |
| 3. First month        | 1. New (< 10)            |         147802  |     0.7734  |            0.2581   |
| 4. First year         | 1. New (< 10)            |         412902  |     0.7462  |            0.2489   |
| 5. Veteran (1+ year)  | 1. New (< 10)            |         397080  |     0.7004  |            0.2316   |
| 1. First day          | 1. New (< 10)            |         883529  |     0.7603  |            0.2302   |

</details>

### Findings
- The issue with this approach is that reputation in `bigquery-public-data.stackoverflow.users` reflects the user's latest state, not their reputation at the time they wrote the question. So I dropped this analysis.
- Instead, I looked at whether more experienced users write better questions. To test this, I checked how many questions each user had already asked (within the public dataset) before posting each new question. 

### Query: [Veterancy](queries/task03/03b_veterancy.sql)

### Results

<details>
  <summary>
    <b>Table I: Answer and Acceptance Rates by Number of Previous Questions Asked</b>
  </summary>

| questions_experience_bucket | total_questions | answer_rate | accepted_answer_rate |
|----------------------------|----------------:|------------:|---------------------:|
| 4. 50+ questions           |        1917481  |     0.8482  |            0.5482   |
| 3. 11-50 questions         |        4103356  |     0.8448  |            0.5315   |
| 2. 1-10 questions          |        8472426  |     0.8338  |            0.4755   |
| 1. First question          |        4257730  |     0.8058  |            0.3811   |

</details>

### Findings
- Users with more experience get better answer rates. This likely means they've learned to write better questions over time.
- To dig deeper, I looked at how questions are structured, specifically how much code they include. We can measure this by counting characters inside `<code>` HTML blocks relative to the total question body.

### Query: [Length of code snippets](queries/task03/03c_length_of_code_snippets.sql)

<details>
  <summary>
    <b>Table J: Question Quality and Answer Metrics by Proportion of Code in Question Body</b>
  </summary>

| code_pct_bucket            | total_questions | avg_code_pct | avg_body_length | avg_code_chars | answer_rate | accepted_answer_rate | avg_answers_per_question |
|---------------------------|----------------:|-------------:|---------------:|--------------:|------------:|---------------------:|------------------------:|
| 2. Low (1-5%)             |        2901666|     0.0264   |      1694.864 |       42.221  |     0.8495  |            0.5428   |         1.3924         |
| 1. Minimal (<1%)          |        1034354|     0.0056   |      3192.511 |       15.390  |     0.8421  |            0.5368   |         1.3632         |
| 3. Moderate (5-10%)       |        1168800|     0.0702   |      1182.173 |       81.703  |     0.8496  |            0.5317   |         1.3952         |
| 4. Significant (10-20%)   |          564836|     0.1357   |        895.388 |      119.570  |     0.8467  |            0.5133   |         1.3838         |
| 5. High (20-40%)          |          148981|     0.2614   |        718.947 |      187.420  |     0.8407  |            0.4890   |         1.3605         |
| 0. No code (0%)           |       13273805|     0.0000   |      1597.576 |        0.000  |     0.8259  |            0.4491   |         1.2859         |
| 6. Very High (40-60%)     |           15225|     0.4687   |        859.497 |      408.482  |     0.8147  |            0.4406   |         1.2635         |
| 7. Mostly Code (60%+)     |            3133|     0.7207   |      2888.432 |    2309.858  |     0.7542  |            0.3712   |         1.1104         |

</details>

### Findings
- Questions with mostly code (60%+) get lower answer and acceptance rates. They tend to be long and hard to parse, which makes them less effective;
- Including some code (1-20%) improves your chances of getting an answer and getting it accepted. But  
too much code has the opposite effect;
- The takeaway: Brevity matters. Next, I looked at title patterns. Since moderate code correlates with better responses, I wanted to see if how the user phrase the title also matters. I used regex to classify titles by type.

### Query: [Title and Length of code snippets](queries/task03/03d_title_and_length_of_code.sql)

<details>
  <summary>
    <b>Table K: Acceptance Rates by Title Pattern and Code Proportion</b>
  </summary>

| title_pattern      | code_pct_bucket     | total_questions | answer_rate | accepted_answer_rate |
|--------------------|--------------------|----------------:|------------:|--------------------:|
| 3. What            | 1. Low (0-5%)      |         54216   |    0.8756   |           0.5994    |
| 3. What            | 2. Moderate (5-20%)|         34084   |    0.8825   |           0.5959    |
| 2. Why             | 1. Low (0-5%)      |        106398   |    0.8457   |           0.5796    |
| 2. Why             | 2. Moderate (5-20%)|         42614   |    0.8420   |           0.5733    |
| 3. What            | 3. High (20%+)     |          3962   |    0.8826   |           0.5644    |
| 6. Other           | 1. Low (0-5%)      |       2677157   |    0.8495   |           0.5483    |
| 1. How-to          | 1. Low (0-5%)      |        699197   |    0.8629   |           0.5436    |
| 6. Other           | 2. Moderate (5-20%)|       1178576   |    0.8497   |           0.5315    |
| 1. How-to          | 2. Moderate (5-20%)|        335464   |    0.8633   |           0.5244    |
| 2. Why             | 3. High (20%+)     |          3509   |    0.8165   |           0.5001    |
| 3. What            | 0. No code         |        170234   |    0.8614   |           0.4978    |
| 6. Other           | 3. High (20%+)     |        107916   |    0.8406   |           0.4930    |
| 1. How-to          | 3. High (20%+)     |         34555   |    0.8579   |           0.4906    |
| 2. Why             | 0. No code         |        244845   |    0.8211   |           0.4776    |
| 5. Error/Problem   | 1. Low (0-5%)      |        399052   |    0.8044   |           0.4718    |
| 6. Other           | 0. No code         |       9024101   |    0.8284   |           0.4574    |
| 5. Error/Problem   | 2. Moderate (5-20%)|        142898   |    0.7992   |           0.4501    |
| 1. How-to          | 0. No code         |       2466240   |    0.8409   |           0.4469    |
| 5. Error/Problem   | 0. No code         |       1368385   |    0.7792   |           0.3875    |
| 5. Error/Problem   | 3. High (20%+)     |         17397   |    0.7641   |           0.3781    |

</details>

### Findings
- "What" and "How-to" titles get the best answer and acceptance rates, especially with 1-20% code. "What" questions in that range hit acceptance rates above 59%;
- "Error/Problem" titles perform the worst across the board. When combined with high code (20%+), acceptance drops below 38%;
- Clear titles + focused code = better questions;
- Finally, I checked whether veteran users actually follow these patterns.

### Query: [Veterancy and questions best-practices](queries/task03/03e_veterancy_and_best_practices.sql)


<details>
  <summary>
    <b>Table L: User Veterancy and questions best-practices </b>
  </summary>

| questions_experience_bucket | total_questions | pct_no_code | pct_low_code | pct_moderate_code | pct_high_code | pct_howto | pct_why  | pct_what | pct_error | pct_other |
|----------------------------|----------------:|------------:|-------------:|------------------:|--------------:|----------:|---------:|---------:|----------:|----------:|
| 1. First question          |        4257735  |     0.7880  |      0.1404  |           0.0637  |       0.0079  |   0.1882  |  0.0207  |  0.0122  |   0.1155  |   0.6634  |
| 2. 1-10 questions          |        8472437  |     0.7395  |      0.1731  |           0.0789  |       0.0084  |   0.1856  |  0.0195  |  0.0133  |   0.1010  |   0.6807  |
| 3. 11-50 questions         |        4103396  |     0.6071  |      0.2665  |           0.1168  |       0.0096  |   0.1755  |  0.0205  |  0.0144  |   0.0930  |   0.6967  |
| 4. 50+ questions           |        2277232  |     0.5104  |      0.3417  |           0.1380  |       0.0099  |   0.1940  |  0.0264  |  0.0172  |   0.0873  |   0.6750  |

</details>

### Findings
- Veterans include code way more often: only 51% post without code vs. 79% for first-timers;
- Experienced users lean toward "How-to", "Why", and "What" titles, and "Error/Problem" titles slightly drop off;
- Finally, veterans learn what works moderate code, clearer titles.

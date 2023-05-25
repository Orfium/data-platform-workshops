# Create & Setup DBT project
## Setup

### orfium-dbt-cookiecutter
Install the cookiecutter (if not installed already)
```shell
> pip install cookiecutter
```
If you have not created your DBT project yet open your terminal and create your project using
```shell
> cookiecutter git@github.com:Orfium/cookiecutter-orfium-dbt.git
```
You will be prompted with a set of configuration parameters. 
* **daap_name** : The name of Orfium's Data Product. It should be the same with the Data Product name that you provided in the `sf-management-pulumi`(e.g. Giannis DaaP )
* **project_name** : This is the project name of the repository. Default value will be the daap_name lowered,split using - delimiter and prefixed with dbt(e.g. giannis-daap, etc.). It is suggested to use the default choice.
* **project_slug** This is the project slug that will be used for all the internal DBT project configuration (e.g, profiles, project name etc.). Default value will be the daap_name lowered and split using _ delimiter (e.g. giannis_daap, etc.)
* **default_target_ci** The name of the default target for the Github Action. You can choose between prod or dev. Default is prod.
* **target_database_prod** : The name of the default database for production target. For this workshop use `db_orfium_testing`.
* **target_database_dev**: The name of the default database for development target. For this workshop use `db_orfium_staging_testing`.
* **target_schema**: The name of the default target schema for all targets. For this workshop use your exposing schema name (e.g `giannsis_daap`)
* **target_user_prod**: The username for the production target. For this workshop use the production user that you enabled in the previous step (e.g `giannis_daap`)
* **target_user_dev**: The username for the dev target. For this workshop use the production user that you enabled in the previous step (e.g `giannis_daap.dev`)
* **target_snowflake_account**: The snowflake account for all targets. For this workshop use `stb70715.us-east-1`  which is the testing account.
* **target_snowflake_role_prod**: (Snowflake specific) The snowflake connection role for production target. For this workshop use the `default` value.
* **target_snowflake_role_dev**: (Snowflake specific) The snowflake connection role for development target. For this workshop use the `default` value.
* **target_snowflake_wh**: (Snowflake specific) The snowflake connection warehouse for all targets. For this workshop use the `default` value.
* **target_postgres_host_prod**: (Postgres specific) The postgres host server from production target. For this workshop the omit it.
* **target_postgres_host_dev**: (Postgres specific) The postgres host server from development target. For this workshop the omit it.

* **run_git_init** A boolean value for instantiating a new github repository. For this workshop use `yes` selection.
* **add_sqlfluff** A boolean value for adding sqlfluff linter configuration. For this workshop use `yes` selection.
* **add_example_project** A boolean value for adding a sample project with example use case on DBT's basic concepts. For this workshop use `yes` selection.

#### Create a new virtual environment
Create a new virtual environment for your local python version, >=3.8 (using pyenv or virtualenv)
```shell
> pyenv virtualenv 3.11.1 dbt-data-platform-workshop
> pyenv activate dbt-data-platform-workshop

or

> virtualenv dbt-data-platform-workshop
> source dbt-data-platform-workshop/bin/activate 
```

#### Install dependencies
```shell
> pip install -r requirements.txt
> pip install -r requirements_dev.txt
```

#### Create a `.env` file
Add the development user's password 
```dotenv
DBT_PASSWORD_PROD=
DBT_PASSWORD_DEV=your_development_user_password
DBT_TEST_ENV=Yes
```


## Run DBT Pipeline in Staging
### Source the local environmental
In order to make the variables in the `.env` variable identifiable to our working session,
we need to export them.
```shell
> export $(grep -v '^#' .env | xargs)
```
### Install your packages
```shell
> dbt deps
```

### Run your seeds
```shell
> dbt seed -t dev
```

### Create your External Table 
By running this command it will automatically define and create the external tables in your sources.
```shell
dbt run-operation stage_external_sources -t dev
```

### Run & Test your Table materialization
```shell
> dbt run -t dev -s +t_customers_orders.sql
> dbt test -t dev -s +t_customers_orders.sql
```

### Run & Test your Incremental materialization
```shell
> dbt run -t dev -s +t_orders_payments.sql
> dbt test -t dev -s +t_orders_payments.sql
```

### Run your View materialization
```shell
> dbt run -t dev -s v_order_payments_per_month.sql
```

### Run your incremental Model with updated data
Go to Snowflake and open the worksheet with the production user, and set the worksheet to the `dev` role.
We will add some more extra data in the `orders` table. 
```sql
SELECT COUNT(*) FROM DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS;

COPY INTO DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS
FROM
    (
        SELECT
            t.$1 AS ID,
            t.$2 AS USER_ID,
            t.$3 AS ORDER_DATE,
            t.$4 AS STATUS,
            substr(split_part(metadata$filename, '/', 3), 6) AS ORDER_YEAR,
            substr(split_part(metadata$filename, '/', 4), 7) AS ORDER_MONTH
        FROM
            @DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS_STAGE as t
    ) 
    PATTERN = 'year=2021/.*'
    FILE_FORMAT = (type = 'csv', skip_header = 1);
    
SELECT COUNT(*) FROM DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS;
```

Then return to your dbt project and run the incremental materialization.
```shell
> dbt run -t dev -s +t_orders_payments.sql
> dbt test -t dev -s +t_orders_payments.sql
```

### Run docs 
```shell
> dbt docs generate
> dbt docs serve --port 8081
```
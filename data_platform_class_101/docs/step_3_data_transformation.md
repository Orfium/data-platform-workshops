# Setup and Run DBT Transformaitons
In this section we will cover the:
1. Setup of a DBT Project.
2. Creating a Snowflake External Table using DBT external packages.
3. Uploading a simple and plain CSV file to Snowflake using DBT seeds.
4. Running scoped DBT model transformations.
5. Running scoped DBT model tests.

The goal of this section is to run in detail all of our pipelines in the development Database, a.k.a DB_ORFIUM_STAGING_TESTING
and then uplaod it to the production Database, a.k.a DB_ORFIUM_TESTING

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
Setup some required environment variables for your project.

* For the `DBT_PASSWORD_PROD` you should specify the password of 
your production programmatic user you enabled at [Enable Production Programmatic User](https://github.com/Orfium/data-platform-workshops/blob/master/data_platform_class_101/docs/step_2_data_pipelines.md#enable-production-programmatic-user).

* For the `DBT_PASSWORD_DEV` ou should specify the password of 
your production programmatic user you enabled at [Enable Development Programmatic User](https://github.com/Orfium/data-platform-workshops/blob/master/data_platform_class_101/docs/step_2_data_pipelines.md#enable-development-programmatic-user).

```dotenv
DBT_PASSWORD_PROD={your_production_user_password}
DBT_PASSWORD_DEV={your_development_user_password}
DBT_TEST_ENV=Yes
DBT_PROFILE_DIR=.
```

### Source the local environmental
In order to make the variables in the `.env` variable identifiable to our working session,
we need to export them.
```shell
> export $(grep -v '^#' .env | xargs)
```

## Run DBT Pipeline in Staging


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
> dbt run-operation stage_external_sources -t dev
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
>Go to Snowflake and open the worksheet  and set the worksheet to the `r_{email_prefix}_dev` role.

In this step we will ingest some more data into the `{email_prefix}_daap_raw.orders` table, 
in order to check if they will be added in the next run of the incremental model.
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

### Run DBT docs
This will generate the DBT documentation for your project and then serve it locally to a webserver.
DBT documentation provide greate insights about the dependencies of your models, as also their configured characteristics.
```shell
> dbt docs generate -t dev
> dbt docs serve --port 8081
```

## Run DBT Pipeline in Production.
Login to snowflake using your `production` programmatic user. 
This is the user that have been activated at step [Enable Production Programmatic User](https://github.com/Orfium/data-platform-workshops/blob/master/data_platform_class_101/docs/step_2_data_pipelines.md#enable-production-programmatic-user).

### Create Stage in Production database
```sql
CREATE OR REPLACE STAGE DB_ORFIUM_TESTING.GIANNIS_DAAP_RAW.PAYMENTS_STAGE  
STORAGE_INTEGRATION = STG_DATA_PLATFORM_101_WORKSHOP
url = 's3://orfium-data-de-dev/workshop_data_platform_101/payments/';
```

### Clone table from staging into production
```sql
CREATE TRANSIENT TABLE DB_ORFIUM_TESTING.GIANNIS_DAAP_RAW.ORDERS CLONE DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS
```

### Run dbt seeds in production
```shell
> dbt seed -t prod
```

### Create your External Table 
By running this command it will automatically define and create the external tables in your sources.
```shell
dbt run-operation stage_external_sources -t prod
```

### Run dbt all models in production
```shell
> dbt build -t prod
```



## Helpful References Links
 * [What is DBT](https://docs.getdbt.com/docs/introduction)
### DBT Configuration
  * [General Configs and Properties](https://docs.getdbt.com/reference/configs-and-properties)
  * [dbt_project.yml](https://docs.getdbt.com/reference/dbt_project.yml)
  * [Snowflake Specific Configuration](https://docs.getdbt.com/reference/resource-configs/snowflake-configs)
  * [Connection Profiles](https://docs.getdbt.com/docs/core/connection-profiles)
### DBT Sources
  * [Sources - How to use](https://docs.getdbt.com/docs/build/sources)
  * [Sources Properties and configuration](https://docs.getdbt.com/reference/source-properties)
### DBT Models
  * [About DBT Models](https://docs.getdbt.com/docs/build/models)
  * [Model properties and configuration](https://docs.getdbt.com/reference/model-properties)
### DBT Tests
  * [About Tests](https://docs.getdbt.com/docs/build/tests)
  * [DBT Great Expectations](https://github.com/calogica/dbt-expectations)
### DBT CLI
  * [DBT CLI Basics](https://docs.getdbt.com/docs/running-a-dbt-project/run-your-dbt-projects)
  * [DBT Model Selection Syntax](https://docs.getdbt.com/reference/node-selection/syntax)
### DBT General
  * [DBT Seeds - How to use](https://docs.getdbt.com/docs/build/seeds)
  * [DBT Enviromental Variables](https://docs.getdbt.com/docs/build/environment-variables)
  * [DBT Project Variables](https://docs.getdbt.com/docs/build/project-variables)
  * [DBT FAQs](https://docs.getdbt.com/docs/faqs)
### DBT Helpful Packages

  * [DBT External Tables](https://github.com/dbt-labs/dbt-external-tables)
  * [DBT Utils](https://github.com/dbt-labs/dbt-utils)
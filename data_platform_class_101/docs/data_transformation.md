# Create & Setup dbt project 

### orfium-dbt-cookiecutter
If you have not create your DBT project yet open your terminal and create your project using
```shell
> cookiecutter git@github.com:Orfium/cookiecutter-orfium-dbt.git
```
You will be prompted with a set of configuration parameters. 
* daap_name : The name of Orfium's Data Product. (e.g. Giannis DaaP )
* project_name: This is the project name of the repository. Default value will be the daap_name lowered,split using - delimiter and prefixed with dbt(e.g. giannis-daap, etc.). It is suggested to use the default choice.
* project_slug This is the project slug that will be used for all the internal DBT project configuration (e.g, profiles, project name etc.). Default value will be the daap_name lowered and split using _ delimiter (e.g. giannis_daap, etc.)
* target_ci The name of the default target for the Github Action. Default is prod.
* target_schema The name of the default target schema.
* run_git_init A boolean value for instantiating a new github repository. Defaults to true (yes).
* add_sqlfluff A boolean value for adding sqlfluff linter configuration. Defaults to false (no).

### Setup 
Before starting running the dbt project we need to prepare your environment.

#### Create a new virtual environment
Create a new virtual environment for your local python version, >=3.8
```shell
> pyenv virtualenv 3.11.1 dbt-giannis-daap
```
#### Install dependencies
```shell
> pip install -r requirements.txt
> pip install -r requirements_dev.txt
```

#### Create a .env file with your project level environmental variables.
```text
DBT_USER=giannis_daap
DBT_USER_STAGING=giannis
DBT_PASSWORD=**************
DBT_PASSWORD_STAGING=**************
DBT_DATABASE=DB_ORFIUM_TESTING
DBT_DATABASE_STAGING=DB_ORFIUM_STAGING_TESTING
DBT_SNOWFLAKE_ACCOUNT=stb70715.us-east-1
DBT_SNOWFLAKE_ROLE=R_GIANNIS_DAAP_MASTER
DBT_SNOWFLAKE_ROLE_STAGING=R_GIANNIS_DAAP_DEV
DBT_SNOWFLAKE_WAREHOUSE=WH_GIANNIS_DAAP
```
Change the environment variables base on your configured resources.

#### Create a new target profile for development
Go to `profiles.yml` file and add a new target profile under the `prod` with the below context
```yaml
dev:
    type: snowflake

    # More information for the options in this file
    # can be found here: https://docs.getdbt.com/dbt-cli/configure-your-profile

    threads: 4

    # Set the DBT_DATABASE in your CI or replace it with the inline value of your database.
    database: "{{ env_var('DBT_DATABASE_STAGING') }}"
    schema: giannis_daap_raw # Change it with your target schema

    # Set variable DBT_USER in your CI or replace it with the inline value of your username.
    user: "{{ env_var('DBT_USER') }}"

    # Set variable DBT_PASSWORD in your CI.
    password: "{{ env_var('DBT_PASSWORD') }}"

    # Additional Snowflake options
    # Find out more about Snowflake config options here:
    # https://docs.getdbt.com/reference/warehouse-profiles/snowflake-profile

    # Keypair authentication use instead of username and password
    # private_key_path: "{{ env_var('DBT_KEY_PATH') }}"
    # private_key_passphrase: "{{ env_var('DBT_KEY_PASSPHRASE') }}"

    # Set the DBT_SNOWFLAKE_ACCOUNT in your CI or update this to the actual Snowflake account like abc12345]
    account: "{{ env_var('DBT_SNOWFLAKE_ACCOUNT') }}"

    # Set the DBT_SNOWFLAKE_ROLE in your CI or update this to the actual role you use in Snowflake
    role: "{{ env_var('DBT_SNOWFLAKE_ROLE_STAGING') }}"

    # Set the DBT_SNOWFLAKE_WAREHOUSE in your CI or update this to the actual Warehouse you use in Snowflake
    warehouse: "{{ env_var('DBT_SNOWFLAKE_WAREHOUSE') }}"

    client_session_keep_alive: False
    query_tag: giannis-daap
```
You should change `schema` and `query_tag` parameters according to your resources.

#### Add the models and schema configuration.
Go to that [link]() and copy all the files under the `/models/giannis_daap_raw` directory into yours relative path. 

#### Add dbt-labs/dbt_external_tables to your local packages.
Go to `package.yaml` and add dbt-labs/dbt_external_tables package
```yaml
  - package: dbt-labs/dbt_external_tables
    version: 0.8.2
```

#### Create the seeds
Create a new folder under the root directory named `seeds` and copy the seeds files from [link]()


## Run DBT Pipeline in Staging

### Install your packages
```shell
> dbt deps
```

### Run your seeds
```shell
> dbt seed -t dev
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
Go to Snowflake and open the worksheet with the `dev` role and run the below commands
```sql
CREATE or REPLACE TRANSIENT TABLE DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS (
    ID NUMBER(38,0),
    USER_ID NUMBER(38,0),
    ORDER_DATE DATE,
    STATUS VARCHAR(25)
);

COPY INTO DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS
FROM @DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS_STAGE/
PATTERN = '.*orders.*'
FILE_FORMAT= (type='csv', skip_header=1);

```
Then return to your dbt project and run the incremental materialization.
```shell
> dbt run -t dev -s +t_orders_payments.sql
> dbt test -t dev -s +t_orders_payments.sql
```

### Run docs 
```shell
> dbt docs generate
> dbt docs serve- -port 8081
```

## Run DBT Pipeline in Production.

### Create required resources.
Open a new worksheet and set it to use your `master` role and your newly created warehouse.

#### Create Stage
```sql
CREATE OR REPLACE STAGE DB_ORFIUM_TESTING.GIANNIS_DAAP_RAW.PAYMENTS_STAGE  
STORAGE_INTEGRATION = STG_DATA_PLATFORM_101_WORKSHOP
url = 's3://orfium-data-de-dev/workshop_data_platform_101/payments/';
```

#### Clone table from staging into production
```sql
CREATE TABLE DB_ORFIUM_TESTING.GIANNIS_DAAP_RAW.ORDERS CLONE DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS
```

#### Run dbt build for production
```shell

```
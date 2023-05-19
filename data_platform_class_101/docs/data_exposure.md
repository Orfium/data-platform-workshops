# Expose your Data to other Data Products.
> In this section you need to split at teams of 2. You will expose your production data to the others Data Product.
## Run DBT Pipeline in Production.
Open a new worksheet and set it to use your `master` role and your newly created warehouse.

### Create Stage
```sql
CREATE OR REPLACE STAGE DB_ORFIUM_TESTING.GIANNIS_DAAP_RAW.PAYMENTS_STAGE  
STORAGE_INTEGRATION = STG_DATA_PLATFORM_101_WORKSHOP
url = 's3://orfium-data-de-dev/workshop_data_platform_101/payments/';
```

### Clone table from staging into production
```sql
CREATE TABLE DB_ORFIUM_TESTING.GIANNIS_DAAP_RAW.ORDERS CLONE DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS
```

### Setup the production password
Open to your `.env` file and add the `DBT_PASSWORD` and source the file again
```shell
> export $(grep -v '^#' .env | xargs)
```

### Run dbt seeds in production
```shell
> dbt seed -t prod
```

### Run dbt all models in production
```shell
> dbt build -t prod
```

## Expose your files to a consumer Data Product
> For this step you need to open again the `sf-management-pulumi` project.

### Rebase or Reset your existing branch
```shell
> git fetch && git rebase origin/data-platform-101
```
or 
```shell
> git fetch && git reset --hard origin/data-platform-101 
```

### Grant Access to your Data Product resources.
> In this sc

1. Create a new module under `projects/orfium_testing/workshop_data_platform_101/data_products/`, 
with a name format as `{email_prefix}_daap_access.py`.
2. Follow the example under `workshop_data_platform_101/data_products_access/giannis_daap_access.py` [link](https://github.com/Orfium/sf-management-pulumi/blob/master/projects/orfium_testing/workshop_data_platform_101/data_products_access/giannis_daap_access.py)
and replace all the references of `giannis` with your `email prefix`.
```python
from orfium_core_pulumi.utils.utils import access_data_product
from workshop_data_platform_101.data_products import giannis_daap

#### Access for giannis_daap - R_GIANNIS_RO ####

giannis_daap_ro_access = access_data_product(
    granter_dp=giannis_daap.data_product_giannis,
    grantee_dps=[
        # Add the grantee data products here.
        # nikos_daap.data_product_nikos,
    ],
    custom_roles=[],
    dev_access=False,
)
```
3. Import the data product module that you want to expose your data. 
Example:
```python
from workshop_data_platform_101.data_products import giannis_daap, niko_daap
```
5. Grant accesses of your `r_ro` role to the imported data products.
Example: 
```python
giannis_daap_ro_access = access_data_product(
    granter_dp=giannis_daap.data_product_giannis,
    grantee_dps=[
        # Add the grantee data products here.
        nikos_daap.data_product_nikos,
    ],
    custom_roles=[],
    dev_access=False,
)
```
3. Run pre-commit for all files `pre-commit run --all-files`
4. Open a new PR to `data-platform-101` 

## Monitor your new access.
Open a Snowflake worksheet with the `r_dev` role 

### Validate access to another Data Product exposed data.
Attempt to read the tables that have been exposed to your Data Product
Example:
```SQL
SELECT * FROM DB_ORFIUM_TESTING.NIKOS_DAAP.T_ORDERS_PAYMENTS limit 10;
```

### Validate no-access to another Data Product's raw data.
Attempt to read a raw table from the Data Product. (You should expect to get an error.)
Example:
```SQL
SELECT * FROM from DB_ORFIUM_TESTING.NIKOS_DAAP.ORDERS limit 10;
```

### Validate no-access to another Data Product's dev data.
Attempt to read a development table from the Data Product. (You should expect to get an error.)
Example:
```SQL
SELECT * FROM from DB_ORFIUM_STAGING_TESTING.NIKOS_DAAP.ORDERS  limit 10;
```
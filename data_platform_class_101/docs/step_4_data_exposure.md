# Expose your Data to other Data Products.
In this section you need to split at teams of 2. You will expose your production data to each other.

This means that your `r_{email_prefix}_ro` (production read-only role), will be inherited to
your **partner's** `r_{partner_email_prefix}_ro_dev`(development read-only role).

In case you are running this step **remotely**, you can use the workshop's default data product
`giannis_daap`, as your partner.

## Setup Steps
> For this step you need to open again the `sf-management-pulumi` project.

### Rebase or Reset your existing branch
Reset or reset your working branch in `sf-management-pulumi` project.
```shell
> git fetch && git rebase origin/data-platform-101
```
or 
```shell
> git fetch && git reset --hard origin/data-platform-101 
```

## Expose your files to a consumer Data Product
In case of running this step in 
### 1.Create new Access Module
Create a new module under `projects/orfium_testing/workshop_data_platform_101/data_products_access/`, 
with a name format as `{email_prefix}_daap_access.py`.

### 2. Define your Data Product Access
Copy the below code block:
   1. Replace all reference of `{email_prefix}` with your email prefix.
   2. Replace the the `{partner_email_prefix}` with your partner's data product that will expose your data product. 

Basically you need to import 

   1. Your data product module `{email_prefix}_daap.py`.
   2. The data product module that you want to expose your data product (e.g. `giannis_daap`, `nikos_daap`)

Then you need to add the imported data product module to the `grantee_dps`. 

> *You can find the existing data products under the `projects/orfium_testing/workshop_data_platform_101/data_products/`.*

```python
from orfium_core_pulumi.utils.utils import access_data_product
from workshop_data_platform_101.data_products import (
    {email_prefix}_daap,
    {partner_email_prefix}_daap 
)

#### Access for {email_prefix} DaaP - R_{email_prefix}_RO ####

{email_prefix}_daap_ro_access = access_data_product(
    granter_dp={email_prefix}_daap.data_product_giannis,
    grantee_dps=[
        # Add the grantee data products here.
        {partner_email_prefix}_daap.data_product_{partner_email_prefix},
    ],
    custom_roles=[],
    dev_access=False,
)
```

### 3. Access default Data Product (In case of running remotely)
1. Go to the `projects/orfium_testing/workshop_data_platform_101/data_products_access/giannis_daap_access.yml`
2. Import your data product module.
```python
from workshop_data_platform_101.data_products import (
    giannis_daap,   # DO NOT REPLACE IT
    {email_prefix}_daap    # Your data product module
)
```
3. Add your imported data product module to the `grantee_dps`
```python
giannis_daap_ro_access = access_data_product(
    granter_dp=giannis_daap.data_product_giannis,
    grantee_dps=[
        # Add your data product reference here.
        {email_prefix}_daap.data_product_{email_prefix},
    ],
    custom_roles=[],
    dev_access=False,
)
```

### 4. Open new Pull Request
* Run pre-commit for all files.
```sh
> pre-commit run --all-files
```
* Open a new PR to `data-platform-101`


## Monitor your grants and new accesses.
Open a Snowflake worksheet with the `r_{email_prefix}_dev` role.

### Validate the access of the partner's data product.
Check the roles that your `r_{email_prefix}_daap_ro` is granted to.
```sql
SHOW GRANTS OF ROLE R_{email_prefix}_DAAP_RO;
```
The results should contain a row that the `grantee_name` is `r_{partner_email_prefix}_RO_DEV`.

### Validate access to another Data Product exposed data.
Attempt to read the tables that have been exposed to your Data Product
Example:
```SQL
SELECT * FROM DB_ORFIUM_TESTING.{partner_email_prefix}_DAAP.T_ORDERS_PAYMENTS limit 10;
```

### Validate no-access to another Data Product's raw data.
Attempt to read a raw table from the Data Product. (You should expect to get an error.)
Example:
```SQL
SELECT * FROM from DB_ORFIUM_TESTING.{partner_email_prefix}_DAAP_RAW.ORDERS limit 10;
```

### Validate no-access to another Data Product's dev data.
Attempt to read a development table from the Data Product. (You should expect to get an error.)
Example:
```SQL
SELECT * FROM from DB_ORFIUM_STAGING_TESTING.{partner_email_prefix}_DAAP.ORDERS  limit 10;
```
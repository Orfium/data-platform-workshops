# Snowflake Access and Resource Management
1. Clone the `sf-mangement-pulumi` project in your machine
2. Checkout your to branch `data-platform-101` 
```shell
> git checkout data-platform-101
```
3. Create a new branch for your workshop material with the name of `dp-101-{email_domain}`
where `email_domain` is your name prefix from your email address. Ex giannis.kontogeorgos@orfium.com -> dp-101-giannis-kontogeorgos
4. Create a new virtual environment using poetry and install the dependencies by running `poetry install`.


> The main submodule that we will reuse will be `projects/orfium_testing/`.

## Create your Data Product
Create your Data Product by following the below steps.
1. Create a new module under `workshop_data_platform_101/data_products/`, with a name format as`{email_prefix}_daap.py` 
2. Follow the example under `workshop_data_platform_101/data_products/giannis_daap.py` [link](https://github.com/Orfium/sf-management-pulumi/blob/master/projects/orfium_testing/workshop_data_platform_101/data_products/giannis_daap.py)
and replace all the references of `giannis` with your email prefix. 
3. Add your data products roles resources under `workshop_data_platform_101/data_products/daap_roles.py` following the existing example.
4. Run pre-commit for all files `pre-commit run --all-files`
5. Open a new PR to `data-platform-101` 
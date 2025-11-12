# Snowflake Access and Resource Management
## Setup `sf-mangement-pulumi`  project. 
### Clone project
Clone the [sf-mangement-pulumi](https://github.com/Orfium/sf-management-pulumi) project in your machine
```shell
> git clone git@github.com:Orfium/sf-management-pulumi.git
```

### Create a branch.
Checkout your to branch `data-platform-101`.
```shell
> git checkout data-platform-101
```

Create a new branch for your workshop material with the name of `dp-101-{email_domain}`
where `email_domain` is your name prefix from your email address. Ex giannis@orfium.com -> dp-101-giannis
```shell
> git checkout -b dp-101-giannis
```
### Create a virtual environment
1. Install poetry, if not already installed. You need `^3.10` python version installed.
```sh
pip install -U poetry
```
or
```sh
pip install -U -r requirements.txt
```

2. Create a new virtual environment using poetry 
```shell
> poetry install --no-interaction --no-root
```

## Create your Data Product
1. Create a new module under `projects/orfium_testing/workshop_data_platform_101/data_products/`, 
with a name format as`{email_prefix}_daap.py`

2. Follow the example under `workshop_data_platform_101/data_products/giannis_daap.py` [link](https://github.com/Orfium/sf-management-pulumi/blob/master/projects/orfium_testing/workshop_data_platform_101/data_products/giannis_daap.py)
and replace all the references of `giannis` with your `email prefix`. 

3. Run pre-commit for all files `pre-commit run --all-files`
4. Open a new PR to `data-platform-101` 
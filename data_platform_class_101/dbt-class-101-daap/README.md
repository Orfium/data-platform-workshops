✌️ GIANNIS DAAP DBT Project ✌️
This is the DBT project for Orfium's GIANNIS DAAP Data Product.

📃 Description
This project is used for all GIANNIS DAAP Data Product's transformations in Snowflake.

🧰 Getting Started
‼️ Prerequisites
Ensure that you have already created a virtual environment. If not follow one of the below links.
Manage your Virtual environment using pyenv
How to use virtual environment?
Activate your newly created virtual environment.
Install pre-commit.
> pip install pre-commit
Install your project dependencies.
> pip install -r requirements.txt
If not already completed, link your local project with Orfium GitHub Business Account by running
Creating the initial commit with all the generated code.
Link your local repository to GitHub with GitHub CLI
Link repository to GitHub using Git
⚙️ Setup
After completed your installation steps, you have to configure GIANNIS DAAP Project for local development.

1. Create local resources.
By default, DBT default DBT_PROFILES_DIR is set to your ~/.dbt/ hidden directory. This env variable describes the directory from which DBT will parse the profiles settings. If you have not created this directory yet create it under your HOME directory along with a profiles.yml configuration file.

> cd && mkdir .dbt && touch .dbt/profiles.yml
Set the DBT_TEST_ENV env variable in your running machine to auto-apply some local configurations.

> export DBT_TEST_ENV=Yes
2. Install DBT Packages.
In order to install all the defined DBT packages in the packages.yml configuration run:

> dbt deps
3. Configure your local profile.
Since you have installed Snowflake provider, below you can find an example configuration:

snowflake_giannis_daap:
  # Target should be `dev` or a relevant identifier for local development.
  target: dev
  outputs:
    dev:
      type: snowflake
      threads: 4
      # Add your target's Database name for local development
      database: "DB_ORFIUM_STAGING"
      # User/password auth
      user: "giannis_daap.dev"
      # Password can be configured explicitly or using environmental variable.
      password: "{{ env_var('DBT_PASSWORD') }}"
      schema: "giannis_daap_raw"

      # Additional Postgres options
      # Find out more about Snowflake config options here:
      # https://docs.getdbt.com/reference/warehouse-profiles/snowflake-profile

      # Keypair authentication use instead of username and password
      # private_key_path: "{{ env_var('DBT_KEY_PATH') }}"
      # private_key_passphrase: "{{ env_var('DBT_KEY_PASSPHRASE') }}"

      # Account can be configured explicitly or using environmental variable.
      account:  yra52994.us-east-1
      role: "R_GIANNIS_DAAP_DEV"
      warehouse: "WH_GIANNIS_DAAP"

      client_session_keep_alive: False
      query_tag: my_tag
Note that if you have already configured other profiles for your local development, then you just have to append the new one at the end of file.

Test the configured profile by running debug command in the project directory.

> dbt debug
For more information about DBT Profiles configuration follow the link

5. Configure your models
In order to create models for the GIANNIS DAAP DBT Project a model folder named under your target schema giannis_daap_raw has been created. Within there is an empty schema.yml model configuration to add your firsts transformations.

If you want you can change the name of your model folder or add more, but keep in mind that you should update your project level model configuration on dbt_project.yml.

models:
  +materialized: view
  +transient:  "{{ true if env_var('DBT_TEST_ENV','No') == 'Yes' else false }}" 
  +persist_docs:
    relation: true
    columns: true
  giannis_daap:
    giannis_daap_raw:
      +schema: giannis_daap_raw

    your_new_models_folder:
      +schema: new_models_target_schema
For more explanation for DBT's schema level configuration go to this confluence link.

6. Use codegen package for fast model definition (Optional)
Generate your sources definition and paste the output result into your models/giannis_daap/schema.yml using the below command
# Example usage
> dbt run-operation generate_source --args '{"schema_name": "giannis_daap_raw", "database_name": "db_orfium_staging"}'
Create your model definition under models/giannis_daap/t_your_first_model.yml

Generate your model configuration and paste it into your models/giannis_daap/schema.yml , using the command below:

> dbt run-operation generate_model_yaml --args '{"model_name": "t_your_first_model"}'

For more advanced usage of dbt-codegen go to project's Github link*
🏃 Running your Models
Run Locally
To simply run all of GIANNIS DAAP models simply run

> dbt run
If you want to run specifically one model then you have to select it using

> dbt run -s t_your_first_model
If you want to run your model and all the downstreamed or upstreamed models associated with it, then use the + operator:

# Run downstream models associated with t_your_first_model
> dbt run -s +t_your_first_model

# Run downstream models associated with t_your_first_model
> dbt run -s t_your_first_model+

# Run both downstream and upstream
> dbt run -s +t_your_first_model+
Same selection logic applies to all other DBT operations such as test, seed, build etc.

For more information related to syntax overview of all DBT operations can be found in this link.

Run/Schedule using Github Actions.
Under the .github/workflows/dbt_schedule_run.yml there is an example GitHub action for running dbt operations on event (push, pull_request etc.) or on schedule.

It uses the dbt-action and on each step a separate operation can be run.

- name: deps
  uses: mwhitaker/dbt-action@v1.1.0
  with:
    command: "dbt deps"

- name: seed
  uses: mwhitaker/dbt-action@v1.1.0
  with:
    command: "dbt seed --full-refresh"
To make this action work you need to add the below secrets into your GitHub repository settings.

DBT_USER
DBT_PASSWORD
DBT_DATABASE
DBT_SNOWFLAKE_ACCOUNT
DBT_SNOWFLAKE_ROLE
DBT_SNOWFLAKE_WAREHOUSE
🤝 Contributing or Support
Contributions, issues and feature requests are welcome!
Feel free to check issues page.
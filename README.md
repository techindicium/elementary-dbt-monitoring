# dbt Monitoring
## This repository is in experimental stage. It is NOT ready for production yet.
### Changes are being made!

This package allows you to easily monitor the quality, dependency, volume, schema and how up-to-date the data is your dbt, providing helpful info to improve your data pipeline.


# :running: Quickstart

New to dbt packages? Read more about them [here](https://docs.getdbt.com/docs/building-a-dbt-project/package-management/).

## Before creating a branch

Pay attention, it is very important to know if your modification to this repository is a release (breaking changes), a feature (functionalities) or a patch(to fix bugs).
With that information, create your branch name like this:

* ```release/<branch-name>```
* ```feature/<branch-name> ```
* ```patch/<branch-name>```

## Requirements
dbt version
* ```dbt version >= 1.0.0```

dbt_utils package. Read more about them [here](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/).
* ```dbt-labs/dbt_utils version: >=0.9.0 and <1.2.0``` 

elementary package. Read more about them [here](https://docs.elementary-data.com/quickstart-cli).
* ``` elementary-data/elementary version: 0.7.1 ```

# Installation elementary package and create first tables to dbt monitoring modelling

## Installation elementary package

1. Include this package in your `packages.yml` file.
```yaml
packages:
  - package: elementary-data/elementary
    version: 0.7.1
```

2. Run `dbt deps` to install the package.

## Configuring models elementary package

1. The package's models can be configured in your `dbt_project.yml` by specifying the package under `models`.

```
models:
    elementary:
        +schema: 'elementary'
```

2. Run `dbt run -m elementary` to build the package inside your dbt project.

"This command will create tables that at first will be empty, but will be fed with the results of these executions of each “dbt run”, “dbt test” and “dbt build” within the project." 

## Installation elementary CLI

Reports can be generated by the elementary package by installing the monitoring module via the CLI. To install it in your project folder, just install elementary according to the used platform:

```
pip install 'elementary-data[snowflake]'
pip install 'elementary-data[bigquery]'
pip install 'elementary-data[redshift]'
pip install 'elementary-data[databricks]'
```

In order to connect, Elementary needs a connection profile in a file named profiles.yml. This profile will be used by the CLI, to connect to the DWH and find the dbt package tables.

The easiest way to generate the profile is to run the following command within the dbt project where you deployed the elementary dbt package:

```
dbt run-operation elementary.generate_elementary_cli_profile
```

Copy the output, fill in the missing fields and add the profile to your profiles.yml. 

```
Profile name: elementary
Schema name: The schema of elementary models, default is <your_dbt_project_schema>_elementary
```

# Installation elementary-dbt-monitoring package and Configuring models

## Installation elementary-dbt-monitoring package

1. Include this package in your `packages.yml` file and specify the version you want to be installed
```yaml
packages:
  - git: https://github.com/techindicium/elementary-dbt-monitoring # insert git SSH URL
        ## revision: v0.1.0 (example, if specific version is needed)
```

2. Run `dbt deps` to install the package.

## Configuring models package

The package's models can be configured in your `dbt_project.yml` by specifying the package under `models` and the start date of the dbt monitoring data and the schema of the sources generated by the elementary package must be declared in vars.

You must declare the `elementary_schema` variable too. The default behavior of the package is, when running with target set as prod, to get the sources from a schema named as `elementary`.

If you set this variable but leave it blank, the sources will be got from the custom schema generated by the macro generated_schema_name by default (it is something like `target.schema ~ '_elementary'`. eg: dev_clark_kent_elementary).

But there is projects that change the behavior of this dbt macro, so we have added the possibility to the user to define the place dbt must have to look for the schema when running with other targets.

It's important to point out that although you have this default behavior in your projetc, you must have to define this variable, but you can leave it blank.

```
models:
    elementary_dbt_monitoring:
        staging:
            materialized: ephemeral
        marts:
            materialized: table
```
...

```
vars:
    elementary_dbt_monitoring:
        dbt_monitoring_start_date: cast('2022-08-01' as date)
        elementary_schema: # Leave it blank if you want to maintain the default behavior of the package
```
## New releases

Want a new release (major/minor/patch) ?
1. Push your modifications to main
2. Push the tag you want, example: "git tag v1.0.1"
3. git push origin tag v1.0.1 or git push --tags (warning: It pushes all tags you have)

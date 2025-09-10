# dummyclient dbt code repository

## Setup Project

Run the following commands to clone the project and then create virtual enviroment

```bash
git clone git@github.com:brainforge-ai/dummyclient.git
cd dummyclient
make dev-env
```

Please use below given template to create a .env file
dot_env is dummy file, please use same env variables but remember to update the values

```bash
    dot_env -> .env
```

Run the following command to add environemtns variable to your virtual env

FOR LINUX

```bash
printf "\nexport \$(grep -v '^#' .env | xargs)" >> env/bin/activate
```

FOR WINDOWS (bash or git bash terminal )

```bash
printf "\nexport \$(grep -v '^#' .env | xargs)" >> env/Scripts/activate
```

# Deployment instructions

## Step 1 - The docker-compose .env file
In order to docker to compile correctly, it need a `.env` file.

This file contains the secrets needed to the application to properly work.
A ` .env ` example file is located here: ` docker/.env `

```yaml
redis_dsn=redis
mysql_dsn=mysql
mysql_user=root
mysql_password=example
jwt_secret=my_secret_key
android_secret_captcha=XXXXXXXXXXXXXXXXXX
ios_secret_captcha=XXXXXXXXXXXXXXXXXX
AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXX
AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXX
```

Replace the `XXXXXXXXXXXX` with your values.

## Step 2 - Docker

Modify the `docker-compose.yml` file to use your own preferred registry where to push the images:
Ex:
```diff
-     image: registry.gitlab.com/coronavirus-outbreak-control/covid-19-consumer-server
+     image: my_registry.io/coronavirus-outbreak-control/covid-19-consumer-server
```

Run docker compose to build and push the image:
```shell script
# docker-compose build
# docker-compose push --ignore-push-failure
```

## Step 3 - Deploy
We used a simple ansible playbook to deploy on AWS cloud EC2 instance.

Go to the `docker/ansible_deploy` directory, create a file named `hosts` and write the ip of your EC2 instances, of course a public ip is needed or a VPN for private AWS ip.

```shell script
# cat hosts
[webserver]
18.xx.xx.xx
19.xx.xx.xx

[webserver:vars]
ansible_python_interpreter=/usr/bin/python3
```

Create a file with your registry credentials and substitute it's name in the `covid19-consumer-playbook.yml` file.

```shell script
# cat my_just_created_login_file.yml
email: my-mail@gmail.com
password: my-password
```

```diff
  tasks:
-   - include_vars: gitlab-registry.login.yml
+   - include_vars: my_just_created_login_file.yml
```

Add amazon pem file to your ssh agent:
```shell script
# ssh-add ~/.ssh/my-amazon.pem
```

Run ansible and wait for deploy:
```shell script
# ansible-playbook -i hosts -u ubuntu covid19-consumer-playbook.yml
```
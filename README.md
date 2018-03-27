## DCUTIL ##
[![Build Status](https://travis-ci.org/faiyaz7283/dcutil.svg?branch=master)](https://travis-ci.org/faiyaz7283/dcutil)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/1686/badge)](https://bestpractices.coreinfrastructure.org/projects/1686)

A utility program for developers to run with docker-compose. The main objective of using DCUTIL - is to make 
running of dev projects on docker containers a cinch. It simply helps automate helpful functions, which in otherwise 
most would do manually. 

- [Installing DCUTIL](#installing-dcutil)
    - [Requirements](#requirements)
    - [Option 1: Execute the installer script remotely](#option-1-execute-the-installer-script-remotely)
    - [Option 2: Clone the project and run the installer](#option-2-clone-the-project-and-run-the-installer)
- [An example usage - basic lemp stack](#an-example-usage---basic-lemp-stack)
    - [Setting up a .env file](#setting-up-a-env-file)
    - [Setting the docker-compose file](#setting-the-docker-compose-file)
    - [Setting up the project](#setting-up-the-project)
    - [Setting up docker](#setting-up-docker)
    - [Run migration](#run-migration)
- [Get help](#get-help)
- [Update](#update)
- [Uninstall](#uninstall)


### Installing DCUTIL ###

You can install DCUTIL in couple of different ways. The easiest and recommended way is to execute the install.sh file 
remotely. The other way is to clone the repo first, then running the install.sh script. 

#### Requirements ####

Please make sure your machine satisfies the list of requirements below. 

- Pre installation dependencies:
    - Git >= 2
    - GNU Bash >= 3
- Post installation dependencies:
    - [Docker](https://docs.docker.com/install) CE/EE
    - GNU Make >= 3
    - awk
    - sed 
    - tput

#### Option 1: Execute the installer script remotely ####

Argument 1 is the directory path where the actual DCUTIL command will be installed. This generally should be a bin folder, 
for example /usr/local/bin or ~/bin. Just make sure that bin directory is on your shell PATH. Argument 2 is the directory 
where you would like to clone the DCUTIL projects git repo. For the examples below, I will use ~/bin for dcutil command 
installation and ~ for DCUTIL git project.

Using curl

```bash
bash <(curl -s https://raw.githubusercontent.com/faiyaz7283/dcutil/master/install.sh) ~/bin ~
```
Using wget

```bash
bash <(wget -O - https://raw.githubusercontent.com/faiyaz7283/dcutil/master/install.sh) ~/bin ~
```

If you are on MacOS, you will need to refresh your current shell to pick up the new changes. For example, refreshing 
.bashrc file.
        
```bash
source ~/.bashrc
```
    
Now you can issue the **dcutil** command from anywhere and run the program.
     
```bash
dcutil
```  

#### Option 2: Clone the project and run the installer ####

Clone the repo. Suggested location is your home directory but you are free to clone it wherever you like.

```bash
cd ~ && git clone https://github.com/faiyaz7283/dcutil.git
```

Change into the cloned project directory and run the installer script.

```bash
cd dcutil && ./install.sh ~/bin ~
```

If you are on MacOS, you will need to refresh your current shell to pick up the new changes. For example, refreshing 
.bashrc file.
        
```bash
source ~/.bashrc
```
    
Now you can issue the **dcutil** command from anywhere and run the program.
     
```bash
dcutil
```  

### An example usage - basic lemp stack ###

Let's see how we can use DCUTIL to aid us with a basic LEMP stack php project. We will be using a very basic 
[TODO web application](https://github.com/faiyaz7283/demo_todo), built with a php framework called 
[Laravel](https://laravel.com). This guide is meant to highlight the core concept of DCUTIL. Once you complete the 
guide, you should be able to use DCUTIL with your own dev project(s). 

DCUTIL requires a .env file with few required variables. One of the most important variable that needs to be set is the 
PROJECTS variable. Basically, you can add as many projects as  using a colon to separate them.

#### Setting up a .env file ####

DCUTIL comes with a .env.example file. We can use this file as a starting point. Its all setup for our demo_todo 
project. Lets move into the dcutil folder and make a copy of .env.example file to .env.

```bash
cd ~/dcutil && cp .env.example .env
```

Once the file finished copying, please open the file in your editor. Let's add a value for the DEMO_TODO_WORKING_DIR. 
This value should be the full directory path where the demo_todo file will be downloaded. For most cases, the location 
of all or multiple projects might be one single location. If that is the case, then its advisable to use the 
HOST_WORKING_DIR variable instead. For example ```HOST_WORKING_DIR==/users/homepage/code```. Let' also add a 
value for the HOST_IP variable. This is the private IP of your host machine. For mac use ```ipconfig getifaddr en0```. 
For linux use ```hostname -I```. For windows use ```ipconfig /all``` and copy the IPv4 address.

#### Setting up the project ####

Now that we have a valid .env file setup. Let's seutp the demo_todo project. DCUTIL needs to know the location where 
the project will reside. If you haven't already set the project's working directory, you will have to do so before the 
next step. The project working directory variable naming convention is simple, add the projects name followed by 
working_dir, all in caps and snake_case. So for our demo_todo project, the var name will be DEMO_TODO_WORKING_DIR.

```bash
dcutil demo_todo build_project
```

Since the project does not yet exists on our working directory, we will be presented with the option to get it from git
repository. Type 1 for yes and press enter.

```
running... build_project
running... p_check
 • Project does not exist.
running... set_code_project
Would you like to get the project from a git repo ?
1) Yes
2) No
``` 

You can let DCUTIL walk you through building the git repo url based on the remote repo github or bitbucket, or use other
to manually enter the full git repo url. Type 3 for other and press enter.

```
running... set_git_code_project
Please select your project repository.
1) github
2) bitbucket
3) other
#?
```

Type the demo_todo git repo https://github.com/faiyaz7283/demo_todo.git and press enter.

```
Enter your full git repository location:
```

The project will be cloned into the project's working directory set in the .env file. Once cloning completes, you will 
be presented with composer task. Since demo_todo is a laravel project, we will need to run composer install to install 
all the package dependencies. Type 1 for Install and press enter.

```
 • Cloning project from https://github.com/faiyaz7283/demo_todo.git.
 • Project demo_todo cloned.
√ set_git_code_project done
√ set_code_project done
running... composer_task
Do you want to run 'composer install' 'composer update' or 'nothing'
1) Install
2) Update
3) Nothing
```

Once composer task is completed, your project setup is done.

```
 • Composer install started.
 ...
 • Composer install completed.
 √ composer_task done
 √ p_check done
 √ build_project done
```

#### Setting up docker ####

Now that we have the demo_todo project all set to go. We need to setup docker to run the project. To get started issue 
the following command.

```bash
dcutil demo_todo build_docker
``` 

We need a docker-compose.yml file to run docker. DCUTIL comes with an example docker compose yml file built to handle a 
basic project like demo_todo. Type 1 for yes and press enter.

```
running... set_cf
Do you want to copy docker-compose.yml.example compose file to /Users/home/diretory/dcutil-library/demo_todo.yml ?
1) Yes
2) No
#?
```

Once the docker-compose.yml file finish setting up, docker_up_detailed with be triggered. Docker compose will run 
through the yml file and download/build images and containers, and bring them up. You should see the end result 
triggered by docker_ps. There should be 4 containers mysql, nginx, php and workstation and their State should all read 
'Up'. 

```
 • Copying docker-compose.yml.example to /Users/home/diretory/dcutil-library/demo_todo.yml
 • Successfully copied.
√ set_cf done
running... docker_up_detailed
...
         Name                       Command              State                    Ports
---------------------------------------------------------------------------------------------------------
demotodo_mysql_1         docker-entrypoint.sh mysqld     Up      0.0.0.0:3306->3306/tcp
demotodo_nginx_1         nginx -g daemon off;            Up      0.0.0.0:443->443/tcp, 0.0.0.0:80->80/tcp
demotodo_php_1           docker-php-entrypoint php-fpm   Up      9000/tcp
demotodo_workstation_1   docker-php-entrypoint php-fpm   Up      9000/tcp
√ docker_up_detailed done
√ build_docker done
```

If there's any container that failed to turn up, most likely due to port collision. Try stopping all running docker 
containers first ``` docker stop $(docker ps -aq) ```. Then run ```dcutil demo_todo docker_up```

#### Running migration ####

The last part of the process is running migration. Since there are many different migration systems for php projects, 
DCUTIL does not include a built in migration function. However, DCUTIL does come with a migration wrapper. It is basically 
just a target name, pointing to the custom make file of the project. All we have to do is provide our own custom 
migration make target and we can run it with DCUTIL. Let see how this can be done.

Back in the [setting the environment file](#setting-the-environment-file) process, we had an option to enter a custom 
make file name. You were suggested to use the default name, which is basically name of the project with the .mk 
extension. The file was created inside the dcutil-library/script. Please open that file and add the following snippet and 
save. 

```makefile
migration :
	@$(MAKE) docker_cmd cnt=workstation cnt_user=dcutil cnt_shell=bash cmd="cd demo_todo && php artisan migrate"
```

Now issue the following command and run the migration.

```
dcutil demo_todo migration
```

### Get help ###

To print the help manual use either the -h, --help or the --man flags.

```bash
dcutil -h
dcutil --help
dcutil --man
```

### Update ###

Use --update or -u flags to update DCUTIL program. It will first check the remote git repo for changes and update 
accordingly. It will also update your DCUTIL command if applicable.

```bash
dcutil -u
dcutil --update
```

### Uninstall ###

To remove DCUTIL from your machine you, run the program with --remove or -r flags.

```bash
dcutil -r
dcutil --remove
```

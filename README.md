## dcutil ##
[![Build Status](https://travis-ci.org/faiyaz7283/dcutil.svg?branch=master)](https://travis-ci.org/faiyaz7283/dcutil)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/1686/badge)](https://bestpractices.coreinfrastructure.org/projects/1686)

The  dcutil  is an utility program written in conjunction with shell script and Make. The main objective of dcutil is to 
setup an organic workflow for project operations running on Docker containers. The name dcutil is short for docker compose 
utility. Docker compose is a great tool to automate and build services, and dcutil simply adds on to that by providing
more helper tools to achieve a full dev operation. 

- [Installing dcutil](#installing-dcutil)
    - [Requirements](#requirements)
    - [Execute the installer script remotely](#execute-the-installer-script-remotely)
- [Setup](#setup)
    - [Setting up the libs dir](#setting-up-the-libs-dir)
    - [Fill in the .env file](#fill-in-the-env-file)
- [Usage](#usage)
    - [The build command](#the-build-command)
    - [Get help](#get-help)
    - [Update](#update)
    - [Uninstall](#uninstall)


### Installing dcutil ###

The easiest and recommended way is to execute the install.sh file remotely. The other way is to clone the repo first, 
then running the install.sh script, but is not suggested. 

#### Requirements ####

Please make sure your machine satisfies the list of requirements below. 
- Git
- Bash
- Docker
- Make

#### Execute the installer script remotely ####

Argument 1 is the directory path where the actual dcutil command will be installed. This generally should be a bin 
folder, for example /usr/local/bin or ~/bin. Just make sure that bin directory is on your shell PATH. Argument 2 and 3 
is optional. Argument 2 is the location of the required libs directory, this can be set after installation. 
Argument 3 is the location where this dcutil repo will be cloned. For most part, you really don't need to set this 
option. By default, dcutil repo will be installed in the same directory where the dcutil command is installed. 

Using curl

```bash
bash <(curl -s https://raw.githubusercontent.com/faiyaz7283/dcutil/master/install.sh) ~/bin
```
Using wget

```bash
bash <(wget -O https://raw.githubusercontent.com/faiyaz7283/dcutil/master/install.sh) ~/bin
```

If you are on MacOS, once installation complete, you will need to refresh your current shell to pick up the new changes. 
For example, refreshing .bashrc file.
        
```bash
source ~/.bashrc
```
    
Now you can issue the **dcutil** command from anywhere and run the program.
     
```bash
dcutil
```  

### Setup ###

In order to start using dcutil, we will need to set a library folder which will hold all of our custom docker-compose 
files, makefiles, configurations etc.

#### Setting up the libs dir ####

Create a new directory, name it anything you like. Then inside that directory create a .env file and create 2 new folders
called docker-compose and makefiles. Once you finish, let dcutil know of this new created directory using --set-libs flag.

```bash
mkdir ~/dcutil-libs
cd ~/dcutil-libs && touch .env && mkdir docker-compose makefiles
dcutil --set-libs ~/dcutil-libs
```

#### Fill in the .env file ####

This is the file, where we set all environment values to be used in our docker-compose files. dcutil also uses this file
to learn about the projects, projects working directory, and project external docker-compose service dependencies. Let 
see some example of setting up the .env file. We will assume, we have currently two code projects called apple and orange, 
and 3 shared services called database, cache and proxy. Shared services are any docker-compose service that
can be connected externally with other docker-compose setup.

Let's add these 5 projects using the PROJECTS variable. When adding multiple items, you have to use a semicolon as separator.
```dotenv
PROJECTS=apple:orange:database:cache:proxy
```

If a project represents multiple grouped projects, then we can set them using the PROJECT_PROJECTS. The idea is, a
project name can be a single code project or a name that points to a group of code projects. Maybe the apple project
doesn't have any code project name apple, but rather web, api and cms. Meanwhile the orange project is a code project.
Then we will only need to define the APPLE_PROJECTS variable. These names are names of the root folders of the project(s)
```dotenv
APPLE_PROJECTS=web:api:cms
```

Now let's see how we connect the main projects with their shared dependncies. The convention is project1:project2:project3. This 
tells dcutil to use all services available from each of these projects. Now if we wanted to use only certain services then we add 
it with pipe. So maybe project1 has 3 shared services defined, and we only need one. From project 2, we need 2 services out of 5.
And from project3 we require all available services. So the above example would change from project1:project2:project3 to
project1|service1:project2|service1|service2:project3. Now let see with our current apple and orange project setup. Project 
apple depends on project proxy's traefik service, project database's mysql service and project cache's redis service. Project 
orange depends on all services from proxy project and mariadb service from database project. The special variable to use to 
declare dependencies is PROJECT_SERVICE_DEPENDENCIES.

```dotenv
APPLE_SERVICE_DEPENDENCIES=proxy|traefik:database|mysql:cache|redis
ORANGE_SERVICE_DEPENDENCIES=proxy:database|mariadb
```

We use the PROJECT_WORKING_DIR variable to tell dcutil the parent folder the code project(s) are in. If all of our code projects 
lives in the same parent directory, then we can we HOST_WORKING_DIR variable instead. We can use PROJECT_WORKING DIRECTORY to 
override HOST_WORKING_DIRECTORY for any projects that might have separate location. We can use full path or relative path. Just keep 
in mind, when we use relative path, it should be relative to the docker-compose folder, as dcutil uses that folder as its base. Let's
assume our apple and orange projects come from different path, meanwhile the databse, cache and proxy projects all have their code 
projects inside a directory called projects. And let say all these direcotires are on same level as the libs folder (parent of 
docker-compose directory).
```dotenv
HOST_WORKING_DIR=../../projects
APPLE_WORKING_DIR=../../dir1
ORANGE_WORKING_DIR=../../dir2
```

We also need to add variables for docker compose files. The convention for docker-compose files is PROJECT_DOCKER_COMPOSE_FILES. 
It accepts one docker-compose file name, or multiple. To add multiple docker-compose files, simply use a : to separate them. You are
free to name these files anything you like. Please refer to docker documents for more info on this [Docker compose](https://docs.docker.com/compose/compose-file/).
```dotenv
APPLE_DOCKER_COMPOSE_FILES=apple.yml
ORANGE_DOCKER_COMPOSE_FILES=orange.yml
```

You will also need to add custom project makefiles to add your project specific tasks to run with dcutil. The convetion for makefile
variable is PROJECT_MAKE_FILE. Again, name them anything you like.
```dotenv
APPLE_MAKE_FILE=apple.mk
ORANGE_DOCKER_COMPOSE_FILES.=orange.mk
```

Here's the .env file putting all the variables together.
```dotenv
# All projects
PROJECTS=apple:orange:database:cache:proxy

# Code projects
APPLE_PROJECTS=web:api:cms

# Service dependencies
APPLE_SERVICE_DEPENDENCIES=proxy|traefik:database|mysql:cache|redis
ORANGE_SERVICE_DEPENDENCIES=proxy:database|mariadb

## Working directories
HOST_WORKING_DIR=../../projects
APPLE_WORKING_DIR=../../dir1
ORANGE_WORKING_DIR=../../dir2

## Docker-Compose files
APPLE_DOCKER_COMPOSE_FILES=apple.yml
ORANGE_DOCKER_COMPOSE_FILES=orange.yml

## Makefiles
APPLE_MAKE_FILE=apple.mk
ORANGE_DOCKER_COMPOSE_FILES.=orange.mk
```

You are free to now add any other variables you like which can be used utilized by your docker-compose files.

### Usage ###
dcutil requires a project name/key(s) to run for most part. Then we follow the project flag with a command and then any 
arguments if needed. The project is a unique flag. This can be called many ways. The most verbose way to use this option 
would be to use the p=project style. You can also omit the p= and simply type the name of the project. You can also use 
the index value of the project. To  find  the  index  value, simply issue the command `dcutil projects` and it will print 
all the available projects along with its key. Use a single key to call one project, or multiple keys to call multiple 
projects. To use multiple keys, you must use : as a delimiter. For example 1:2:5 would call projects associated with keys 
1, 2 and 5 respectively.

Also make sure to add your project specis docker-compose file(s) inside the docker-compose folder, and custom project specific 
makefiles inside the makefiles folder.

#### The build command ####
dcutil comes with a command called build. It is basically a wrapper that loops though all the code projects and calls 3 
make targets, before_tasks, <code_project>_tasks and after tasks. You have to create these targets inside your project makefile
and do anything you like. Both before tasks and after tasks sits our side project loop, so, they can be utilized to perform
non project related tasks. Lets use the apple and orange project from above example.

Heres a makefile for the apple project. As defined in the .env file, apple project has 3 code projects called, web, cms and api. 
```makefile
before_tasks :
	@echo "Running before tasks..."

web_tasks :
	@echo "Running web tasks..."

cms_tasks :
    @echo "Running cms tasks..."

api_tasks : 
    @echo "Running api tasks..."

after_tasks :
	@echo "Running after tasks..."  
```

Heres a makefile for orange project.
```makefile
before_tasks :
	@echo "Running before tasks..."

orange_tasks :
	@echo "Running orange tasks..."

after_tasks :
	@echo "Running after tasks..."  
```

Now save the files in the makefiles folder. Now lets see how we can use the build command.

Run build for all projects 
```bash
dcutil --all build
```
Run build for one project 
```bash
dcutil apple build
```
Run build for multiple specified project 
```bash
dcutil 1:2 build
```
Run build for one project with one specified code project 
```bash
dcutil apple build code_projects=web
```
Run build for one project with multiple specified code projects 
```bash
dcutil apple build code_projects=web:cms
```

#### Get help ####

To print the help manual use either the -h, --help or the --man flags. Or you can invoke the manpage via ```man dcutil```.
```bash
dcutil --help
```

#### Update ####

Use --update or -u flags to update dcutil program. It will first check the remote git repo for changes and update 
accordingly. It will also update your dcutil command if applicable.
```bash
dcutil --update
```

#### Uninstall ####

To remove dcutil from your machine you, run the program with --remove or -r flags.
```bash
dcutil --remove
```

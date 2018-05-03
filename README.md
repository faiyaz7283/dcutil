## DCUTIL ##
[![Build Status](https://travis-ci.org/faiyaz7283/dcutil.svg?branch=master)](https://travis-ci.org/faiyaz7283/dcutil)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/1686/badge)](https://bestpractices.coreinfrastructure.org/projects/1686)

The  dcutil  is an utility program written in conjunction with shell script and Make. The main objective of dcutil is to 
setup an organic workflow for project operations running on Docker containers. The name dcutil is short for docker compose 
utility. Docker compose is a great tool to automate and build services, and dcutil simply adds on to that by providing
more helper tools to achieve a full dev operation. 

- [Installing DCUTIL](#installing-dcutil)
    - [Requirements](#requirements)
    - Execute the installer script remotely](#execute-the-installer-script-remotely)
- [An example usage - basic lemp stack](#an-example-usage---basic-lemp-stack)
    - [Setup the DCUTIL libs dir](#setup-the-dcutil-libs-dir)
    - [Usage](#usage)
- [Get help](#get-help)
- [Update](#update)
- [Uninstall](#uninstall)


### Installing DCUTIL ###

The easiest and recommended way is to execute the install.sh file remotely. The other way is to clone the repo first, 
then running the install.sh script, but is not suggested. 

#### Requirements ####

Please make sure your machine satisfies the list of requirements below. 

- Pre installation dependencies:
    - Git >= 2
    - GNU Bash >= 3
- Post installation dependencies:
    - [Docker](https://docs.docker.com/install) CE/EE
    - GNU Make >= 3

#### Execute the installer script remotely ####

Argument 1 is the directory path where the actual DCUTIL command will be installed. This generally should be a bin 
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

### An example usage - basic lemp stack ###

Let's see how we can use DCUTIL to aid us with a basic LEMP stack php project. We will be using a very basic 
[TODO web application](https://github.com/faiyaz7283/demo_todo), built with a php framework called 
[Laravel](https://laravel.com). This guide is meant to highlight the core concept of DCUTIL. Once you complete the 
guide, you should be able to use DCUTIL with your any project(s). 

DCUTIL requires a libs folder, holding the .env file and a directory name docker-compose. One of the main 
variable that needs to be set first is the PROJECTS variable. Basically, you can add as many projects as you like, using 
a colon to separate them.

#### Setup the DCUTIL libs dir ####

DCUTIL comes with a dcutil-libs-example directory with everything in it to get started. you should copy the directory to
your home directory, or wherever easier. 

```bash
cp -R dcutil-libs-example ~/dcutil-libs
```

Now that we have a libs directory, wewill need to tell dcutil where to find it.

```bash
dcutil --set-libs ~/dcutil-libs
```

#### Usage ####

Still under developement.


### Get help ###

To print the help manual use either the -h, --help or the --man flags. Or you can get the manpage with ```man dcutil```.

```bash
dcutil --help
```

### Update ###

Use --update or -u flags to update DCUTIL program. It will first check the remote git repo for changes and update 
accordingly. It will also update your DCUTIL command if applicable.

```bash
dcutil --update
```

### Uninstall ###

To remove DCUTIL from your machine you, run the program with --remove or -r flags.

```bash
dcutil --remove
```

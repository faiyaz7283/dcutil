CREATE DATABASE IF NOT EXISTS `demo_todo` COLLATE 'utf8_general_ci' ;
GRANT ALL ON `demo_todo`.* TO 'default'@'%' ;

FLUSH PRIVILEGES ;
<?php
//全局session_start
session_start(); 
//全局居设置时区
date_default_timezone_set('Asia/Shanghai');
//全局设置默认字符
header('Content-type:text/html;charset=utf-8');
//定义数据库连接参数
define('DBHOST', getenv('DBHOST') ?: 'localhost');
define('DBUSER', getenv('DBUSER') ?: 'root');
define('DBPW', getenv('DBPW') ?: 'root');
define('DBNAME', getenv('DBNAME_XSS') ?: 'pkxss');
define('DBPORT', getenv('DBPORT') ?: '3306');

?>

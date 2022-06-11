CREATE USER 'user_readonly'@'127.0.0.1' IDENTIFIED BY 'notroot';
GRANT SELECT, SHOW VIEW ON rebibbia2.* TO 'user_readonly'@'127.0.0.1';
FLUSH PRIVILEGES;

ALTER USER 'user_readonly'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY 'notroot';
flush privileges;

GRANT EXECUTE ON rebibbia2.* TO 'user_readonly'@'127.0.0.1';
flush privileges;

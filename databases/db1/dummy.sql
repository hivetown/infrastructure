CREATE DATABASE hivetown;
USE hivetown;
CREATE TABLE users (id INT NOT NULL AUTO_INCREMENT, name VARCHAR(255) NOT NULL, PRIMARY KEY (id));
INSERT INTO users (name) VALUES ('John');
INSERT INTO users (name) VALUES ('Mary');
INSERT INTO users (name) VALUES ('Peter');

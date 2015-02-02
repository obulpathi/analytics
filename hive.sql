-- Use Hive to process logs and aggregate analytics

-- What are the things as a user of website, I would like to know?
-- Country, Browser, Date and Time, URL, etc .,


-- Copy data into HDFS
hadoop fs -ls
hadoop fs -copyFromLocal apache.log apache.log
hadoop fs -ls


Hive
Libraries: ls /usr/lib/hive/lib


LIST JARS;
ADD JAR /usr/lib/hive/lib/hive-contrib.jar;
LIST JARS;


-- Drop table, if exists
DROP TABLE logs;


-- CREATE TABLE
CREATE TABLE logs(
  host STRING,
  country STRING,
  browser STRING,
  time STRING,
  request STRING,
  status STRING,
  size STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
  "input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) ([^ \"]*|\"[^\"]*\") (-|[0-9]*) (-|[0-9]*)?",
  "output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s");

CREATE TABLE logs(
    host STRING,
    country STRING,
    browser STRING,
    time STRING,
    method STRING,
    url STRING,
    protocol STRING,
    status STRING,
    size STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
    "input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) \"([^ ]*) ([^ ]*) ([^ ]*)\" (-|[0-9]*) (-|[0-9]*)?",
    "output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s %8$s %9$s");

CREATE TABLE logs(
    host STRING,
    country STRING,
    browser STRING,
    time STRING,
    method STRING,
    path STRING,
    query STRING,
    protocol STRING,
    status STRING,
    size STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
    "input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) \"([^ ]*) ([^ \\?]*)(\\?[^ ]*)? ([^\"]*)\" (-|[0-9]*) (-|[0-9]*)?",
    "output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s %8$s %9$s %10$s");

64.242.88.10 USA Opera [07/Mar/2004:22:03:19 -0800] "GET /twiki/bin/rdiff/Main/VishaalGolam HTTP/1.1" 200 5055
64.242.88.10 USA Opera [07/Mar/2004:22:04:44 -0800] "GET /twiki/bin/view/Main/TWikiUsers?rev=1.21 HTTP/1.1" 200 6522

-- Load data into table
LOAD DATA INPATH 'apache.log' INTO TABLE logs;
-- LOAD DATA INPATH 'apache.log' OVERWRITE INTO TABLE logs;


-- Sample Query
SELECT * FROM logs WHERE browser = 'Firefox' LIMIT 20;


-- Lets query
SELECT SUM(size) FROM logs;
SELECT COUNT(*) FROM logs;
SELECT country, COUNT(*) FROM logs GROUP BY country;
SELECT browser, COUNT(*) FROM logs GROUP BY browser;
SELECT country, SUM(size) FROM logs GROUP BY country;
SELECT browser, SUM(size) FROM logs GROUP BY browser;
SELECT country, browser, COUNT(*) FROM logs GROUP BY country, browser;

SELECT day(from_unixtime(unix_timestamp(time,'[dd/MMM/yyyy:HH:mm:ss Z]'))), COUNT(*)
FROM logs
GROUP BY day(from_unixtime(unix_timestamp(time,'[dd/MMM/yyyy:HH:mm:ss Z]')));

SELECT hour(from_unixtime(unix_timestamp(time,'[dd/MMM/yyyy:HH:mm:ss Z]'))), COUNT(*)
FROM logs WHERE day(from_unixtime(unix_timestamp(time,'[dd/MMM/yyyy:HH:mm:ss Z]')))=8
GROUP BY hour(from_unixtime(unix_timestamp(time,'[dd/MMM/yyyy:HH:mm:ss Z]')));


-- URL
SELECT path, COUNT(*) AS clicks FROM logs GROUP BY path;
SELECT path, COUNT(*) AS clicks, SUM(size) AS bytes FROM logs GROUP BY path;
SELECT status, COUNT(*) AS returned FROM logs GROUP BY status;

Data: hadoop fs -ls /apps/hive/warehouse

INSERT OVERWRITE LOCAL DIRECTORY '/root/analytics/country'
SELECT country, COUNT(*) FROM logs GROUP BY country
FIELDS TERMINATED BY ',';

INSERT OVERWRITE LOCAL DIRECTORY '/root/analytics/browser'
SELECT browser, COUNT(*) FROM logs GROUP BY browser;

INSERT OVERWRITE LOCAL DIRECTORY '/root/analytics/day'
SELECT day(from_unixtime(unix_timestamp(time,'[dd/MMM/yyyy:HH:mm:ss Z]'))), COUNT(*)
FROM logs
GROUP BY day(from_unixtime(unix_timestamp(time,'[dd/MMM/yyyy:HH:mm:ss Z]')));

-- Load data in MySQL
SHOW DATABASES;
CREATE DATABASE analytics;
SHOW TABLES;
CREATE TABLE country (name VARCHAR(20), owner VARCHAR(20));

LOAD DATA INFILE '/root/analytics/country/000000_0' INTO TABLE country;

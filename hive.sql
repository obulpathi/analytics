-- Use Hive to process logs and aggregate analytics

-- What are the things as a user of website, I would like to know?
-- Country, Browser, Date and Time, URL, etc .,


-- Copy data into HDFS
hadoop fs -ls
hadoop fs -copyFromLocal apache.log apache.log


Hive
Libraries: ls /usr/lib/hive/lib


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


-- Load data into table
LOAD DATA INPATH 'apache.log' INTO TABLE logs;
-- LOAD DATA INPATH 'apache.log' OVERWRITE INTO TABLE logs;


-- Sample Query
SELECT * FROM logs WHERE browser = 'Firefox' LIMIT 2;


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
SELECT COUNT(DISTINCT url) FROM logs;

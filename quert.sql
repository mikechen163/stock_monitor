select (time) from lastest_records_1m where code= '399905' order by id desc limit 20;
select * from lastest_records_1m where code= '399905' order by id desc limit 20;



select (time) from lastest_records where code= '399905' order by id desc limit 20;
select (time) from lastest_records_5m where code= '399905' order by id desc limit 20;
select (date) from lastest_records_5m where code= '399905' order by id desc limit 20;

ruby sync.rb -c /Users/mike/usbbackup "/Volumes/My Passport/photo"
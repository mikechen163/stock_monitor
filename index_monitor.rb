# Be sure to change the mysql_connection details and create a database for the example

#monitor the index 399905/000300 60minutes/30minutes  macd paramater 

#$: << File.dirname(__FILE__) + '/../lib'

$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  


require 'sqlite3'
require 'active_record'
require 'open-uri'
require 'time'

require 'network_stock_interface'
require 'db_interface'

include Network_stock_interface
include Db_interface

sa = [ 

          "DROP TABLE lastest_records_1m",
          "create table  lastest_records_1m ( id integer primary key,
                code                        varchar(6),    
                date                       DATE, 
                time                       TIME,
                open                       float,  
                high                       float,  
                low                       float,  
                close                       float,  
                volume                     float,
                amount                     float,
                ema_short                   float,
                ema_long                    float,
                diff                        float,
                dea                         float,
                macd                        float,
                ma5                         float,
                ma10                         float,
                ma20                         float,
                ma30                         float,
                ma60                         float
                )",

 "DROP TABLE lastest_records_5m",
          "create table  lastest_records_5m ( id integer primary key,
                code                        varchar(6),    
                date                       DATE, 
                time                       TIME,
                open                       float,  
                high                       float,  
                low                       float,  
                close                       float,  
                volume                     float,
                amount                     float,
                ema_short                   float,
                ema_long                    float,
                diff                        float,
                dea                         float,
                macd                        float,
                ma5                         float,
                ma10                         float,
                ma20                         float,
                ma30                         float,
                ma60                         float
                )",

 "DROP TABLE lastest_records_15m",
          "create table  lastest_records_15m ( id integer primary key,
                code                        varchar(6),    
                date                       DATE, 
                time                       TIME,
                open                       float,  
                high                       float,  
                low                       float,  
                close                       float,  
                volume                     float,
                amount                     float,
                ema_short                   float,
                ema_long                    float,
                diff                        float,
                dea                         float,
                macd                        float,
                ma5                         float,
                ma10                         float,
                ma20                         float,
                ma30                         float,
                ma60                         float
                )",

 "DROP TABLE lastest_records_30m",
          "create table  lastest_records_30m ( id integer primary key,
                code                        varchar(6),    
                date                       DATE, 
                time                       TIME,
                open                       float,  
                high                       float,  
                low                       float,  
                close                       float,  
                volume                     float,
                amount                     float,
                ema_short                   float,
                ema_long                    float,
                diff                        float,
                dea                         float,
                macd                        float,
                ma5                         float,
                ma10                         float,
                ma20                         float,
                ma30                         float,
                ma60                         float
                )",

 "DROP TABLE lastest_records_60m",
          "create table  lastest_records_60m ( id integer primary key,
                code                        varchar(6),    
                date                       DATE, 
                time                       TIME,
                open                       float,  
                high                       float,  
                low                       float,  
                close                       float,  
                volume                     float,
                amount                     float,
                ema_short                   float,
                ema_long                    float,
                diff                        float,
                dea                         float,
                macd                        float,
                ma5                         float,
                ma10                         float,
                ma20                         float,
                ma30                         float,
                ma60                         float
                )",

          "DROP TABLE suggestion",
          "create table  suggestion ( id integer primary key,
                code                        varchar(6),    
                date                       DATE, 
                time                       TIME,
                peroid                     float,
                act                        varchar(6), 
                price                      float
                )",
 



          "DROP TABLE name",
          "create table  name ( id integer primary key,
                code                        varchar(6),    
                name                        varchar(20),
                market                      varchar(2)

               )"

        

   ]

     
 #p ta

class Lastest_records_1m < ActiveRecord::Base
  def self.table_name() "lastest_records_1m" end
end

class Lastest_records_5m < ActiveRecord::Base
  def self.table_name() "lastest_records_5m" end
end

class Lastest_records_15m < ActiveRecord::Base
  def self.table_name() "lastest_records_15m" end
end

class Lastest_records_30m < ActiveRecord::Base
  def self.table_name() "lastest_records_30m" end
end

class Lastest_records_60m < ActiveRecord::Base
  def self.table_name() "lastest_records_60m" end
end


class Names < ActiveRecord::Base
  def self.table_name() "name" end
   def self.get_name(code)
     rec=self.where(code: "#{code}")
     return rec[0]['name'] if rec!=nil
     return "unknown"
  end 

  def get_name_list
     self.all.map{|rec| rec['market']+rec['code']}    
  end
end

class Suggestion < ActiveRecord::Base
  def self.table_name() "suggestion" end
end



 class Peroid
   attr_accessor :peroid, :last_t, :trading_time_flag

   def initialize(peroid)
     @peroid = peroid
     @last_t = Time.now
     @trading_time_flag = false
   end

   def time_up?(t)

    # p @trading_time_flag
    # p today_is_trading?
     if (@trading_time_flag == false )
        if today_is_trading?
          @last_t = t
          @trading_time_flag = true
          return true
        end        
     end

     if ((t-@last_t)>=@peroid) and (@trading_time_flag)
               #p.call(ta,@peroid,show_log) 
               @last_t = t
               return true
      end

      return false
   end

 end

def print_help
    puts "This Tool is used to import data from stock software like ZhaoShangZhengquan"
    puts "-c            initialize the database"
    puts "-a [seconds]  get data from sina from given peroid "  
    puts "-h            This help"    
end

 if ARGV.length != 0
 
    ARGV.each do |ele|       
     if  ele == '-h'          
      print_help
      exit 
     end 

     if ele == '-c'
      db_name = ARGV[ARGV.index(ele)+1]
      connect_db(db_name)
      
      create_db(sa)
      load_name_into_db("all_name.txt")
    end
  
    if ele == '-a'
      db_name = ARGV[ARGV.index(ele)+1]
      connect_db(db_name)

      #seconds = ARGV[ARGV.index(ele)+2].to_i
      #seconds = 60 if seconds==0

      #ta = get_name_list("all_name.txt")
      ta=['sz399905','sh000300','sh000016']

      last_t = Time.now.gmtime #utc time
       date = last_t.to_date
       t2 = Time.new(date.year,date.month,date.day,9,30,0,"+08:00").gmtime
      t3 = Time.new(date.year,date.month,date.day,11,30,59,"+08:00").gmtime
      t4 = Time.new(date.year,date.month,date.day,13,0,0,"+08:00").gmtime
      t5 = Time.new(date.year,date.month,date.day,15,0,59,"+08:00").gmtime

       # t = last_t
       # if ((t>=t2) and (t<=t3)) or ((t>=t4) and (t<=t5))

       # end
      trading_time_flag = false 
      show_log = true
      #show_log = true if seconds >= 300

      pl = [1,5,15,30,60].map{|x| Peroid.new(x*60)}
      #p pl
      #return 
      while (true)
        t = Time.now.gmtime
        #if (t-last_t)>=seconds
         # last_t = t
        #


          pl.each do |po|
            if ((t>=t2) and (t<=t3)) or ((t>=t4) and (t<=t5))
            #if true 
            #


              class_name = "Lastest_records_"+(po.peroid/60).to_s+"m" 
              update_data_from_sina(ta,class_name,po.peroid,show_log) if po.time_up?(t) 
            else
               if po.trading_time_flag
                 class_name = "Lastest_records_"+(po.peroid/60).to_s+"m"
                 update_data_from_sina(ta,class_name,po.peroid,show_log)
                 puts "Trade is over, fetch last #{po.peroid/60}m data. " 
               end
               po.trading_time_flag = false
              
              #puts "#{t.strftime("%y-%m-%d %H:%M:%S")} not on trading .."
            end
          end
        #end


        sleep(1)
      end
  
    end

    if ele == '-t'
      p today_is_trading?
    end



  end
end

 if ARGV.length == 0
  print_help
 end



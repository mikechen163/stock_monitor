# Be sure to change the mysql_connection details and create a database for the example

#ruby$: << File.dirname(__FILE__) + '/../lib'
$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  

require 'sqlite3'
require 'active_record'
require 'open-uri'
require 'time'
#require 'logger'
#  class Logger
#    def format_message(severity, timestamp, msg, progname) "#{msg}\n" end
#  end


#$flog = File.new("ar.log","w+") if $flog == nil

#ActiveRecord::Base.logger = Logger.new($flog)
# ActiveRecord::Base.establish_connection(
#   :adapter  => "sqlite3", 
#   :host     => "localhost", 
#   #~ :username => "root", 
#   #~ :password => "", 
#   :database => "quicktrade.db"
# )

#$log = []

require 'network_stock_interface'
require 'db_interface'

include Network_stock_interface
include Db_interface

sa = [ 

          "DROP TABLE lastest_records",
          "create table  lastest_records ( id integer primary key,
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

     


#create_db(sa)




 #p ta

class Lastest_records < ActiveRecord::Base
  def self.table_name() "lastest_records" end
end

class Names < ActiveRecord::Base
  def self.table_name() "name" end
  def self.get_name(code)
     rec=self.where(code: "#{code}")
     #p rec
     return rec[0]['name'] if rec!=nil
     return "unknown"
  end 

  def self.get_name_list
     self.all.map {|rec| rec['market']+rec['code']}   
  end
end

class Suggestion < ActiveRecord::Base
  def self.table_name() "suggestion" end
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

      seconds = ARGV[ARGV.index(ele)+2].to_i
      seconds = 3600 if seconds==0

      ta = Names.get_name_list
      #p ta

      last_t = Time.now.gmtime
       date = last_t.to_date
        t2 = Time.new(date.year,date.month,date.day,9,30,0,"+08:00").gmtime
      t3 = Time.new(date.year,date.month,date.day,11,30,59,"+08:00").gmtime
      t4 = Time.new(date.year,date.month,date.day,13,0,0,"+08:00").gmtime
      t5 = Time.new(date.year,date.month,date.day,15,0,59,"+08:00").gmtime

       # t = last_t
       # if ((t>=t2) and (t<=t3)) or ((t>=t4) and (t<=t5))

       # end
      trading_time_flag = false 
      show_log = false
      show_log = true if seconds >= 300
      while (true)
        t = Time.now.gmtime

        if (t-t2) > 3600
           date = t.to_date
           t2 = Time.new(date.year,date.month,date.day,9,30,0,"+08:00").gmtime
           t3 = Time.new(date.year,date.month,date.day,11,30,59,"+08:00").gmtime
           t4 = Time.new(date.year,date.month,date.day,13,0,0,"+08:00").gmtime
           t5 = Time.new(date.year,date.month,date.day,15,0,59,"+08:00").gmtime
        end
        #if (t-last_t)>=seconds
         # last_t = t
         if (t.wday>=1) and (t.wday<=5)

          if ((t>=t2) and (t<=t3)) or ((t>=t4) and (t<=t5))
           #if true
             if (not trading_time_flag ) 
               if (today_is_trading?)
                 update_data_from_sina(ta,"Lastest_records",seconds,show_log) 
                 last_t = t
                 trading_time_flag = true 
               end
             end
          
             if (trading_time_flag ) and ((t-last_t)>=seconds)
                 update_data_from_sina(ta,"Lastest_records",seconds,show_log) 
                 last_t = t
             end

            # if ((t-last_t)>=seconds) or (trading_time_flag == false)
               
            #    update_data_from_sina(ta,"Lastest_records",seconds,show_log) 
            #    last_t = t
            #    trading_time_flag = true
               
            # end

          else
             if trading_time_flag
                 # update_data_from_sina(ta,"Lastest_records",seconds,show_log)
                 # last_t = t
                 puts "Trade is over for  #{seconds/60}m . " 
              end

            trading_time_flag = false
            #puts "#{t.strftime("%y-%m-%d %H:%M:%S")} not on trading .."
          end
        end


        sleep(1)
      end
  
    end




  end
end

 if ARGV.length == 0
  print_help
 end

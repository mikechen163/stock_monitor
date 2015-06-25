
require 'sqlite3'
require 'active_record'

module Db_interface


 def connect_db(db_name)
   ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3", 
  :host     => "localhost", 
  #~ :username => "root", 
  #~ :password => "", 
  :database => db_name
   )
 end

def create_db(sa)
      sa.push("COMMIT")
     
      sa.each { |statement|
         # Tables doesn't necessarily already exist
         begin; ActiveRecord::Base.connection.execute(statement); rescue ActiveRecord::StatementInvalid; end
      } 
end



def insert_data(table,sl)

   

  sa = [ 
          "BEGIN TRANSACTION"]

       sl.each do |s|  

          if (s[0]>='0') and (s[0]<='9')
            ts= "insert into #{table} values (#{s})" 
          else
            ts=s.to_s
          end

          #puts ts

         sa.push(ts)
       end

     

      sa.push("COMMIT")
     
      sa.each { |statement|
         # Tables doesn't necessarily already exist
         begin; ActiveRecord::Base.connection.execute(statement); rescue ActiveRecord::StatementInvalid; end
      } 

end

def update_data(table,sl)

  sa = [ 
          "BEGIN TRANSACTION"]

       sl.each do |s|  

          ts= "update #{table} set #{s}  " 

          #puts ts

         sa.push(ts)
       end

     

      sa.push("COMMIT")
     
      sa.each { |statement|
         # Tables doesn't necessarily already exist
         begin; ActiveRecord::Base.connection.execute(statement); rescue ActiveRecord::StatementInvalid; end
      } 

end

def load_name_into_db(fname)
  lid = 1
  sl = []
  File.open(fname) do |file|
      file.each_line do |line|
        code = line.scan(/\([0-9]+\)/)[0][1..6]
        ind = line.index(code)
        name = line[0..ind-2]
        price = line.scan(/[0-9]+\.[0-9]+/)[0].to_f
        market = "sz"
        market = "sh" if code[0]=='6' 
        market = "sh" if (code =='000016') and (price > 1000.0)
        market = "sh" if (code =='000300') 

        ts = "#{lid},'#{code}','#{name}','#{market}'"
        sl.push(ts)
        lid += 1
      end
  end

  insert_data('name',sl)
end


# def get_name_list(fname)
#   ta = []
#   File.open(fname) do |file|

     
#       file.each_line do |line|
#         code = line.scan(/\([0-9]+\)/)[0][1..6]
#         ta.push( code)
        
#         #break
#       end
#   end

#   return ta
# end



end



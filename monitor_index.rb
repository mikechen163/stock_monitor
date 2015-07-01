#monitor daily macd index  中文
$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
require 'time'

#require 'rupy'
require 'csv'

require 'tushare_interface'
# require 'json'
# require 'pp'

def format_roe(roe)
  #p roe
  r = (roe*100).to_i
  #p r.class
  return r/100.0
end

#$ema_p=[12,26,9]
#$ema_p=[6,30,9]

def ema(x,n,p)
  return (x*2+(n-1)*p)/(n+1)
end

def show_history(ta,two_way=false,show_macd=false)
  #p dir
  #cl_list=["SH601988.txt","SH601398.txt","SH601328.txt"]
  #cl_list = ["SZ399905.txt","SH000300.txt"]
  #cl_list = ["SZ399905.txt","SH000300.txt"]

  i=0
  arr=[[],[]]
  #date_list=[nil,nil,nil]
  #cl_list.each do |afile|
  # prefix = "SZ"
  # prefix= "SH" if code[0]=='6'
  # prefix= "SH" if code=='000300'

  #fname = "#{dir}\/#{prefix}#{code}.txt"

    #p fname
    total_roe = 1.0
    #arr[i]=[]
    j=0
     # File.open(fname,:encoding => 'gbk') do |file|       
     #    file.each_line do |line|
          len = ta.length
          #ta[1..len-1].each do |na| 
          ta.each do |na|
              #p na
              #day_num = Time.new(line[6..9].to_i,line[0..1].to_i,line[3..4].to_i,0,0,0).to_date
              day_num = na[0]
              #date_list[i].push(day_num)
               #td,open,high,low,close,volume,amount = line.split(/\t/)
               #close = na[3]
               close=na[1]["close"]
              

               h=Hash.new
               h[:date] = day_num
               h[:price] = close.to_f

               if j==0
                 h[:ema_short] = close.to_f
                 h[:ema_long] = close.to_f
                 h[:diff]=0.0
                 h[:dea]=0.0
                 h[:macd]=0.0
                 h[:last_price] = close.to_f
                 h[:last_action] = :null
              

               else

                last=arr[i][j-1]
                #p last
                price = close.to_f
                #h[:ema_short]=last[:ema_short]*11.0/13 + 2.0/13*price
                #h[:ema_long] =last[:ema_long]*25.0/27 + 2.0/27*price
                h[:ema_short] = ema(price,$ema_p[0],last[:ema_short])
                h[:ema_long] = ema(price,$ema_p[1],last[:ema_long])

                h[:diff] = h[:ema_short] - h[:ema_long]
                #h[:dea]  = last[:dea]*8.0/10+h[:diff]*2.0/10
                h[:dea]  = ema(h[:diff],$ema_p[2],last[:dea])
                h[:macd] = 2*(h[:diff]-h[:dea])

                
                h[:last_price]  = last[:last_price]
                h[:last_action] = last[:last_action]

                ts =""
                ts = "diff=#{format_roe(h[:diff])}, dea=#{format_roe(h[:dea])}, macd=#{format_roe(h[:macd])}," if show_macd

                 if (h[:diff] > h[:dea]) and (last[:diff]< last[:dea])
                   #p h[:last_price]
                   roe = -(price-h[:last_price])/h[:last_price]*100
                   if two_way
                     total_roe = total_roe*(1+roe/100)
                     puts "#{h[:date].to_s} #{ts} diff>dea, sdSxuggest to buy #{price}, last roe=#{format_roe(roe)}%, total roe=#{format_roe(total_roe*100)}%" 
                   else
                    puts "#{h[:date].to_s} #{ts} diff>dea, suggest to buy #{price}"         
                   end
                   h[:last_price] = price
                   h[:last_action] = :buy
                 end

                  if (h[:diff] < h[:dea]) and (last[:diff]> last[:dea])
                   roe = (price-h[:last_price])/h[:last_price]*100
                   total_roe = total_roe*(1+roe/100)
                   #p total_roe
                   puts "#{h[:date].to_s} #{ts} diff<dea, suggest to sell #{price}, last roe=#{format_roe(roe)}%, total roe=#{format_roe(total_roe*100)}%" 
                   h[:last_price] = price
                   h[:last_action] = :sell
                 end

               
               end

               arr[i][j]=h

               j+=1

          #end
        #end
      end

       
      last=arr[i][j-1]
      price =last[:price]
      last_price=last[:last_price]
      roe = (price-last_price)/last_price*100

      #p last[:last_action].to_s
      if (last[:last_action] == :buy) or (two_way)
        roe = -roe if (last[:last_action] == :sell) 
        total_roe = total_roe*(1+roe/100)

                   #p total_roe
        puts "#{last[:date].to_s}  price=#{price}, last roe=#{format_roe(roe)}%, total roe=#{format_roe(total_roe*100)}%" 
      end
                  

    i+=1
  #end

  #return date_list[0]
end



def print_help
    puts "This Tool is used to show analysis daily macd for given stock "
    puts "-c [dir] [code] analysis code using dir"
    puts "-h              This help"    
end
#main start here...

 #Rupy.start
 if ARGV.length != 0
 
    ARGV.each do |ele|       
     if  ele == '-h'          
      print_help
      exit 
     end 

    #  if ele == '-c'
    #   dir = ARGV[ARGV.index(ele)+1]
    #   code = ARGV[ARGV.index(ele)+2]
    #   ema = ARGV[ARGV.index(ele)+3].to_i
      
    #   $ema_p=[12,26,9]
    #   $ema_p=[6,30,9] if ema==1
    #   get_day_list_from_file(dir,code,false,false)
    # end

    if ele == '-n'
      # dir = ARGV[ARGV.index(ele)+1]
      # code = ARGV[ARGV.index(ele)+2]
      # ema = ARGV[ARGV.index(ele)+3].to_i
      
      # $ema_p=[12,26,9]
      # $ema_p=[6,30,9] if ema==1
      # get_day_list_from_file(dir,code,false,false)


      code = ARGV[ARGV.index(ele)+1]
      start_date = ARGV[ARGV.index(ele)+2]
      end_date = ARGV[ARGV.index(ele)+3]
       kcode = ARGV[ARGV.index(ele)+4]

      t=Tushare.new
      ta=t.get_history_data(code,start_date,end_date,kcode)
      #ta.each {|h| p h}
      $ema_p=[12,26,9]
      #$ema_p=[6,30,9] if ema==1
      show_history(ta,false,false)

    end


  end
end

#Rupy.stop


require 'time'
require 'open-uri'

module Network_stock_interface

  def today_is_trading?
    ok=false
    today = Time.now.localtime("+08:00").to_date.to_s

    #while not ok
        ta=get_list_data_from_sina(['399905'])
        #p ta[0][:date]
        #today = Time.now.to_date
        #p today.to_s
        if ta[0][:date] == today
          return true
        else
          #puts "not trading day, sleeping 60 seconds ..."
          sleep(60)
          return false
        end
    #end

  end

  def get_list_data_from_sina(codelist)

  sl = ""

  codelist.each do |code|
    pref = "sh"
    pref = "sz" if (code[0]!='6')  
    pref = "sh" if (code =='000300') or (code =='000016') 


    #hk02208  gb_bidu sh000016
    pref = "" if (code[0]=='h') or (code[0]=='g') or (code[0]=='s')



    if sl.length >0
      sl += ","+ pref + code 
    else
      sl = pref+code
    end

  end

  uri="http://hq.sinajs.cn/list=#{sl}"

  #p uri

  #return
   
    html_response = nil  
    open(uri) do |http|  
      html_response = http.read  
    end 

    #p html_response

    rl =  html_response.split("hq_str_")
    #p rl[0]
    #p rl[1]
    #p rl[2]
    tta=[]

    rl.each_with_index do |str,i|
      #sa=str.scan(/[0-9]\,/)
      if i != 0
        #p str
        sa=str.split(',')
        len = sa.length
        #p sa
    
        #ta=[ sa[0][2..7], sa[1].to_f,sa[4].to_f,sa[3].to_f,sa[5].to_f,sa[8].to_i,sa[9].to_i]

        if sa[8].to_f > 0
          h= Hash.new
          h[:code] = sa[0][2..7]
          # h[:date] = Time.now.to_date
          # time_str = Time.now.gmtime.to_s[11..18]
          # h[:time] = (time_str[0..1].to_i+8).to_s+time_str[2..7]
          h[:date] = sa[len-3]
          h[:time] = sa[len-2]
          h[:open] = sa[1].to_f
          h[:high] = sa[4].to_f
          h[:low]   = sa[5].to_f
          h[:close] = sa[3].to_f 
          h[:volume] = sa[8].to_f
          h[:amount] = (sa[9].to_i/100).to_f/100
         # h[:ratio] = 0.0
          #h[:ratio] = (h[:close]-h[:open])/h[:open]*100 if h[:open] >0
          tta.push(h) 
        end
      end
    end

    #p tta
    return tta

    #sa= html_response.split('http://vip.stock.finance.sina.com.cn/quotes_service/view/vMS_tradehistory.php?symbol')  

    #return sa

    # sa=html_response.scan(/[0-9]\,/)
    # p sa
    # sa=html_response.scan(/[0-9]+\.[0-9]+/)
    # p html_response.index(sa[6])
    # index = html_response.index(sa[6])+sa[6].length
    # p index
    #sa=html_response.split(',')
    
    #return sa[1].to_f,sa[4].to_f,sa[3].to_f,sa[5].to_f,sa[8].to_i,sa[9].to_f
 end

 def fetch_data_from_sina(cl)

  batch_num = 300
 
  len = cl.length
  #p len

  step = 0
  all = []

    #t1= Time.now
  while (step < len)
     a_end = step+batch_num-1
     a_end = len-1 if a_end > len 
     #p step
     #p a_end
     tl = get_list_data_from_sina(cl[step..a_end])
     #p tl

     all += tl
     step += batch_num

       #   len_new = tl.length
       # tl[0..len_new-1].each do |h|
       # #puts "#{format_code(h[:code])} on #{Time.now.strftime("%m-%d %H:%I:%M")}, price=#{format_price(h[:close])}, ratio=#{format_roe(h[:ratio])},amount=#{format_price(h[:amount])} " 
       # puts "#{(h[:code])} on #{Time.now.strftime("%m-%d %H:%I:%M")}, price=#{(h[:close])}, ratio=#{(h[:ratio])},amount=#{(h[:amount])} " 
       # end
  end
   # t2 = Time.now
#    puts "fetching all data from sina takes #{t2-t1} seconds."
 
  return all
  #p (t2.usec-t1.usec)/1000
  

  
end

  def update_data_from_sina(ta,class_name,peroid,show_log=false)

        t1 = Time.now 
        all=fetch_data_from_sina(ta)
        t2 = Time.now
        puts "#{t1.getlocal("+08:00").strftime("%y-%m-%d %H:%M:%S")} fetching all data from sina for #{peroid/60}m takes #{t2-t1} seconds."

        #class_name = "Lastest_records_"+(peroid/60).to_s+"m" 
        #p class_name
        currentDb = Object.const_get(class_name)
        #p currentDb.to_s
        #return
        

        line_list= []
        sl = []
        rec=currentDb.last
        s_rec=Suggestion.last

        if rec==nil
          did = 1  
        else
          did = rec.id+1
     
        end


        if s_rec==nil   
          sid = 1
        else
          sid = s_rec.id+1
        end



        #p all.length

         all.each do |h|
             #puts "#{(h[:code])} on #{Time.now.strftime("%m-%d %H:%I:%M")}, price=#{(h[:close])}, ratio=#{(h[:ratio])},amount=#{(h[:amount])} " 
             #code = h[:code]
             #puts "process #{h[:code]} ... "
             w_list = currentDb.where(code: "#{h[:code]}").last(60)

         
             #day = Time.now.to_date
             #time = 
              ts = "#{did}"
              ts=h.values.inject(ts) {|res,var| res << ",'#{var.to_s}'"}

             len = w_list.length 
             if len == 0
               ts << ",'#{h[:close]}','#{h[:close]}',0.0,0.0,0.0,'#{h[:close]}','#{h[:close]}','#{h[:close]}','#{h[:close]}','#{h[:close]}'"
             else
               rec=w_list[len-1]
               price = h[:close]
               ema_short=rec['ema_short']*11.0/13 + 2.0/13*price
               ema_long =rec['ema_long']*25.0/27 + 2.0/27*price

               diff = ema_short - ema_long
               dea  = rec['dea']*8.0/10+diff*2.0/10
               macd = 2*(diff-dea)

               #p get_name_str(h[:code])

               if (diff > dea) and (rec['diff']< rec['dea'])
                
                 system ("say #{get_sound(peroid,:buy,h[:code],price)}") if (peroid > 60) 

                 puts "at #{h[:date]} #{h[:time]} #{peroid/60}m  diff>dea , #{get_name_str(h[:code])} suggest to buy  at #{price}" if show_log
                 #$log.push({:action=>:buy,:time=>h[:time],:code=>h[:code],:price=>price})
                 #sl.push("#{sid},'#{h[:code]}',#{h[:date]},#{h[:time]},'buy',#{price}")
                 sl.push("#{sid},'#{h[:code]}','#{h[:date].to_s}','#{h[:time].to_s}','#{peroid}','buy','#{price}'")
                 sid += 1
               end

                if (diff < dea) and (rec['diff'] > rec['dea'])
  
                 system ("say #{get_sound(peroid,:sell,h[:code],price)}") if peroid > 60

                 puts "at #{h[:date]} #{h[:time]} #{peroid/60}m  diff<dea , #{get_name_str(h[:code])} suggest to sell at #{price}" if show_log
                 #$log.push({:action=>:sell,:time=>h[:time],:code=>h[:code],:price=>price})
                 sl.push("#{sid},'#{h[:code]}','#{h[:date].to_s}','#{h[:time].to_s}','#{peroid}','sell','#{price}'")
                 sid += 1
               end

               pl = w_list.collect{|rec| rec['close']}

               ts << ",'#{ema_short}','#{ema_long}','#{diff}','#{dea}','#{macd}','#{calc_ma(5,pl)}','#{calc_ma(10,pl)}','#{calc_ma(20,pl)}','#{calc_ma(30,pl)}','#{calc_ma(60,pl)}'"

             end

              #ts = "#{did},\'#{fcode.to_s}\',date(\'#{day}\'),#{open},#{high},#{low},#{close},#{volume},#{amount},#{week},#{month}"
              #puts ts
              line_list.push(ts)
              did += 1
         end

         insert_data(currentDb.to_s,line_list)
         insert_data('suggestion',sl)
   end

  

  def calc_ma(num,list)
   len = list.length
   start = (len>num ? len-num : 0)
   total = list[start..len-1].inject(0.0) {|res,var| res + var}
   dv = (len>num ? num : len)
   return total/dv
  end

  
  def get_sound(peroid,direction,code,price)
    action = "买入"
    action = "卖出" if direction == :sell 

    #p code
    #name = Names.get_name(code)
    name = nil
    name = "中证500指数" if (code=='399905') 
    name = "沪深300指数" if (code=='000300') 
    name = "上证50指数" if (code=='000016') and (price > 1000.0) #这个代码和股票代码重叠，根据价格大于1000决定
 
    #p name if name!=nil
    return "根据#{peroid/60}分钟指标分析，可以#{action}#{name}了" if name!=nil
    name = Names.get_name(code)
    return "#{action}#{name}"

  end

  def get_name_str(code)
    name = Names.get_name(code)
    return "#{name}(#{code})"
  end


end
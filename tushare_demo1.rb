require 'rupy'
require 'csv'
require 'json'
require 'pp'



class Tushare

  def initialize()
  
  	@ts=Rupy.import("tushare")

  end

  def get_h_data(code,start_date,end_date)
  	 r = @ts.get_h_data(code,start_date,end_date)
     #s=r.to_json('records').to_s
     #p s
     #return JSON.parse(s)
     s=r.to_csv.to_s
     return CSV.parse(s)
  end

end

# t=Tushare.new
# h=t.get_h_data('002508','2015-06-01','2015-06-24')
# h.each {|line| p line}

def arr_to_hash(ta)

  ha=[]
  header = ta[0]
  len = ta.length
  ta[1..len-1].each do |na|
    tt=header.each_with_index.map {|x,i| [x,na[i]]}
    h = Hash[tt]
    ha.push(h)
  end

  return ha
end

Rupy.start
 if ARGV.length != 0
 
    ARGV.each do |ele|       
     # if  ele == '-h'          
     #  print_help
     #  exit 
     # end 

     if ele == '-h'
      code = ARGV[ARGV.index(ele)+1]
      start_date = ARGV[ARGV.index(ele)+2]
      end_date = ARGV[ARGV.index(ele)+3]

      t=Tushare.new
      ta=t.get_h_data(code,start_date,end_date)

      ha = arr_to_hash(ta)
      ha.each {|h| p h}

    end
   end
end

Rupy.stop
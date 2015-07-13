def to_str(size)

	return "#{size}" if size < 1024
	return "#{((size/1024.0)*100).to_i/100.0}K" if size < 1024*1024
	return "#{((size/1024.0/1024)*100).to_i/100.0}M" if size < 1024*1024*1024
	return "#{((size/1024.0/1024/1024)*100).to_i/100.0}G" 

	len = s.length
	s+' '*(10-len)
end

def walk(dir1,level=0,print_level=3)
	ta=[]
	totalsize = 0

	Dir.glob("#{dir1}\/.*").each do |afile|
		#p afile
		if (afile!="#{dir1}/.") and (afile!="#{dir1}/..")
		  ta.push(afile)
		end
	end

	Dir.glob("#{dir1}\/*").each do |afile|
		ta.push(afile)		
	end

	ta.each do |item|
		#p item
		#walk(item)	
        if FileTest.directory?(item) 
        	#p item
		    totalsize += walk(item,level+1,print_level)
        else
          totalsize += FileTest.size(item)
        end
    end

    s = to_str(totalsize)
    len = s.length
	s += ' '*(8-len)

   puts "#{s} | #{dir1}" if level<print_level
   return totalsize
end

#travel directory and count all file size .
walk(ARGV[0],0,ARGV[1].to_i) if FileTest.directory?(ARGV[0]) 


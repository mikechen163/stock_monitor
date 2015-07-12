  #require 'FileUtils'

# def sync_dir(dir1,dir2)
# 	Dir.glob("#{dir1}\/.*").each do |afile|
# 		p afile
# 	end

# 	Dir.glob("#{dir1}\/*").each do |afile|
# 		p afile
# 	end

# end

#sync_dir(".","")


# list=Dir.entries('.')
# p list

# list.each_index do |x| 
#    #FileUtils.cp "#{list[x]}",%%2 if !File.directory?(list[x]) 
#    p list[x]
# end 

def ns(s1,s2)
	len=s2.length
	ind = s1.index(s2)

	return s1[(ind+len)..s1.length-1]
end

require 'find'
require 'FileUtils'
#require ''

#total_size = 0

#Find.find(ENV["HOME"]) do |path|
#dir1="/Users/mike/usbbackup"
#dir2="/Volumes/nt/photo"

def copy_dir(dir1,dir2)
	Find.find(dir1) do |path|
	  #p path
	  if FileTest.directory?(path)
	    if File.basename(path)[0] == '.'
	      Find.prune       # Don't look any further into this directory.
	    else
	      #all directory branch
	      #p path 
	      np= dir2+ns(path,dir1)
	      if !Dir.exist?(np) #path not found in dest directory,create it.
	      	p "creating new directory: #{np}"
	      	Dir.mkdir(np)
	      else
	      	#p np
	      end

	      next
	    end
	  else
	  	  # all file branch
	  	  np= dir2+ns(path,dir1)
	  	  if !File.exist?(np) #file not found ,copy source file to dest directory
	      	p "copy file : #{np}"
	      	FileUtils.cp path,np
	      else
	      	#p np
	      	#file exist, check file size is identical ?
	      	size1=FileTest.size(path)
	      	size2=FileTest.size(np)
	      	if size1!=size2
	      	  p "#{ns(path,dir1)} SIZE is different, diff=#{size2-size1}" 
	       	  FileUtils.cp path,np
	        end
            
	      end
	  	#p path
	    #total_size += FileTest.size(path)
	  end
	end
end

#copy_dir('/Users/mike/weblog',"/Users/mike/test")

def print_help
    puts "This Tool copy all files in source_directory to dest_dir, mkdir if necessay"
    puts "-c [src_dir] [dest_dir]   "
    puts "-h  This help"    
end

 if ARGV.length != 0
 
    ARGV.each do |ele|       
     if  ele == '-h'          
      print_help
      exit 
     end 

     if ele == '-c'
      src_dir = ARGV[ARGV.index(ele)+1]
      dest_dir = ARGV[ARGV.index(ele)+2]
      if !Dir.exist?(src_dir)
      	p "source #{src_dir} not exist!!"
      	exit
      end

      if !Dir.exist?(dest_dir)
      	p "dest #{dest_dir} not exist!!"
      	exit
      end

      copy_dir(src_dir,dest_dir)
    end
   end
end

 if ARGV.length == 0
  print_help
 end
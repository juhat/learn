class Dirlist
  
  def initialize(actdir)
    @files = []
    @dirs = []
    @actual_dir = actdir + '/*'
  end
  def list
    Dir.glob(@actual_dir).each do |f|
      if File.directory?(f)
        @dirs.push({:text=>File.basename(f), :iconcls=>'folder', :leaf=> false})
      else
        @files.push({:text=>File.basename(f), :iconcls=>'file-txt', :id=>(f), :leaf=> true, :qtip=>'tooltip'})
      end
    end
    return @dirs + @files
  end
  
end
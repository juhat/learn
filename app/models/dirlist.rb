# Read files from a working dir, 
# and provide a file/dir list to the UI
class Dirlist

  def initialize(actdir)
    @files = []
    @dirs = []
    @actual_dir = Dirlist.clean(actdir + '/*')
  end
  
  # Clean working path from special signs
  def self.clean(path)
    path.gsub!(/\.\./, '')
    path.gsub!(/\/\//, '/')
    return path
  end  
  
  # List files/dirs
  def list
    Dir.glob(@actual_dir).each do |f|
      unless f.include?('learn')
        if File.directory?(f)
          # if File.writable?(f)
            @dirs.push({:text=>File.basename(f), :iconcls=>'folder', :leaf=> false})
          # else
            # @dirs.push({:text=>File.basename(f), :iconcls=>'folder', :disabled=>true, :leaf=> false})
          # end
        else
          # if File.writable?(f)
            @files.push({:text=>File.basename(f), :iconcls=>'file-txt', :id=>(f), :leaf=> true, :qtip=>'tooltip'})
          # else
            # @files.push({:text=>File.basename(f), :iconcls=>'file-txt', :id=>(f), :leaf=> true, :disabled=>true,:qtip=>'tooltip'})
          # end
        end
      end
    end
    return @dirs + @files
  end
  
end
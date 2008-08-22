class TreeController < ApplicationController
  protect_from_forgery :only => [:retek]

  def railsconsole
    result = nil
    begin
      result = eval(params[:command])
    rescue Exception => ex
      result = ex.to_s
    end
    render :text=> result
  end
  def terminal
    t = Thread.new { `cd public/A && #{params[:command]}` }
    render :text=>t.value
  end
  
  def download
    baseDir = 'public/'
    
    logger.info(params) 
  end
  
  def form
    baseDir = 'public/'
    case params[:cmd]
      when 'load'
        # sleep 2
        # TODO waitMSG
        render :file => baseDir + params[:path]
      when 'save'
        file = File.new(baseDir + params[:path], 'w')
        file.write(params[:note])
        file.close
        render :text=>'{"success":true,"error":""}'
    end 
  end
  
  def getls
    baseDir = 'public/'
    
    if request.get? 
      logger.info('get') 
    else 
      logger.info('post') 
    end
    logger.info(params[:cmd]) 
    
    
    case params[:cmd]
      when 'get'
        dr = Dirlist.new(baseDir + params[:path])
        render :json => dr.list
        # respond_to do |format|
        #   format.html # render static index.html.erb
        #   format.json { render :json => dr.list }
        # end
      when 'rename'
        begin
          unless File.directory?(baseDir + params[:oldname])
            File.rename(baseDir + params[:oldname], baseDir + params[:newname])
          else
            # handling dir rename
          end
        rescue
          render :json => '{"success":false,"error":"Cannot rename file root/a.txt to root/abc.txt"}'
        else
          render :json => '{"success":true}'
        end
        
      when 'newdir'
        begin
          Dir.mkdir(baseDir + params[:dir])
        rescue
          render :json => '{"success":false,"error":"Cannot create dir..."}'
        else
          render :json => '{"success":true}'
        end
        
      when 'delete'
        begin
          
        rescue
          render :json => '{"success":false,"error":"Cannot delete file..."}'
        else
          render :json => '{"success":true}'
        end
        
      when 'upload'
    end
  end
end

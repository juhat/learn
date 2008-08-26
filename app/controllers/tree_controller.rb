class TreeController < ApplicationController
  
  # before_filter :token, :only=> [:console, :terminal]

  protect_from_forgery :only => [:retek]

  def token
    conf = YAML.load(File.open("#{RAILS_ROOT}/config/LEARN_user_token.yml"))
    logger.info config.user_token
    # logger.info('baj van')
    unless (params[:user_token] == conf['user_token'])
      render :text=>'Nem vagy jogosult a megtekintesre..'
      false
    end
  end
  
  def console
    result = nil
    begin
      result = eval(params[:command])
    rescue Exception => ex
      result = ex.to_s
    end
    render :text=> result
  end
  
  def terminal
    t = Thread.new { `cd /home/user1/test && #{params[:command]}` }
    tval = t.value
    t.exit! 
    render :text=>tval
  end
  
  def file
    baseDir = '/home/user1/test/'
    case params[:cmd]
      when 'load'
        render :file => baseDir + params[:path]
      when 'save'
        file = File.new(baseDir + params[:path], 'w')
        file.write(params[:note])
        file.close
        render :text=>'{"success":true,"error":""}'
    end 
  end
  
  def filepanel
    baseDir = '/home/user1/test/'
    
    case params[:cmd]
      when 'get'
        dr = Dirlist.new(baseDir + params[:path])
        render :json => dr.list
      when 'rename'
        begin
          File.rename(Dirlist.clean(baseDir + params[:oldname]),
                      Dirlist.clean(baseDir + params[:newname]))            
        rescue
          render :json => '{"success":false,"error":"Cannot rename file root/a.txt to root/abc.txt"}'
        else
          render :json => '{"success":true}'
        end
      when 'newdir'
        begin
          Dir.mkdir(Dirlist.clean(baseDir + params[:dir]))
        rescue
          render :json => '{"success":false,"error":"Cannot create dir..."}'
        else
          render :json => '{"success":true}'
        end
      when 'delete'
        begin
          FileUtils.rm_r(Dirlist.clean(baseDir + params[:file]))
        rescue
          render :json => '{"success":false,"error":"Cannot delete file..."}'
        else
          render :json => '{"success":true}'
        end
      when 'upload'
    end
  end
end

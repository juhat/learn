require 'hpricot'
require 'net/http'

class LearnController < ApplicationController  
  before_filter :ajax_call, :except => [:filepanel, :autotest, :file, :terminal, :console, :db]
  skip_before_filter :verify_authenticity_token
  # protect_from_forgery :only => [:retek]
  before_filter :login_required
  
  def index
    @user = current_user
    current_user.start_learn
    render :layout=>'learn'
  end

  def restart
    current_user.restart_course
    redirect_to :controller => :learn
  end
  
  # Proxied back to backend.
  # TODO: Restarting of backend is not the best deal, it is a workaround.
  # It just needid because the backend code is cached even in development mode.
  def autotest
    # current_user.restart_course_server
    # path = '/learn_course/autotest'
    # 
    # logger.info("Proxied autotest to backend to #{current_user.course_host + path}.")
    # 
    # res = Net::HTTP.get(current_user.course_host, path)
    # 
    # # logger.info(res)
    # 
    # header = File.readlines("#{current_user.path}/active/spec/learn_story.html").map{|l| l.rstrip}.to_s
    # render :text => header + res
    # # TODO: text parsing, template to make html
    render :text => "TODO"
  end

  # Proxied terminal back to backend.
  def terminal
    # params[:command].gsub!(/;/, '')
    # params[:command].gsub!(/&/, '')
    
    begin
      output = `sudo su -c "cd #{current_user.lesson_path}; #{params[:command]}" #{current_user.os_user}`
    rescue StandardError => e
      output = e.message
    end
    
    logger.info("Terminal command: #{params[:command]}")
    logger.info(output)
    render :text => output
  end

  # Proxied app console back to backend
  def console
    render :text => "TODO"

    # path = "http://#{current_user.course_host}/learn_course/console"
    # begin
    #   res = Net::HTTP.post_form(URI.parse(path),{'command' => params[:command]}).body
    # rescue StandardError => e
    #   res = e.message
    # end
    # logger.info("Proxied app console command to backend to #{path}.")
    # logger.info(res)
    # render :text => res
  end
  
  # Proxied db console back to backend
  def db
    render :text => "TODO"

    # path = "http://#{current_user.course_host}/learn_course/db"
    # begin
    #   res = Net::HTTP.post_form(URI.parse(path),{'command' => params[:command]}).body
    # rescue StandardError => e
    #   res = e.message
    # end
    # logger.info("Proxied db console command to backend to #{path}.")
    # logger.info(res)
    # render :text => res
  end
  
  def file
    baseDir = current_user.lesson_path
    path = File.join( baseDir, params[:path] )
    tmpfile = "/tmp/#{ Time.now.to_i }.txt"
    case params[:cmd]
      when 'load'
        render :text => `sudo su -c "cat #{ path }" #{ current_user.os_user }`
      when 'save'
        logger.info( "FILEPANEL WRITE to #{ path }" )
        file = File.new( tmpfile, 'w')
        file.write(params[:note])
        file.close
        
        rcode = run_code "sudo su -c \"cp #{ tmpfile } #{ path }\" #{current_user.os_user}"
        
        run_code "rm -f #{ tmpfile }"
        
        logger.info(rcode)
        if rcode == 0
          render :text=>'{"success":true,"error":""}'
        else
          render :text=>'{"success":false,"error":""}'
        end
    end 
  end
  
  def run_code( code )
    logger.info( 'RUN > ' + code )
    rsp = `#{ code }`
    if $?.to_i == 0
      logger.info( "RETURN 0 > #{rsp}" )
    else
      logger.error( "RETURN #{$?.to_i} > #{rsp}" )
    end
    return $?.to_i
  end
  private :run_code
  
  def filepanel
    baseDir = current_user.lesson_path
    
    case params[:cmd]
      when 'get'
        logger.info "FILEPANEL: Reading #{params[:path]}"
        dr = Dirlist.new( File.join( baseDir, params[:path] ) )
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
  
  
  private
  def ajax_call
    if request.xhr?
      render :layout =>false
    end
    return true
  end
end

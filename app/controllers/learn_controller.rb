require 'hpricot'
require 'net/http'

class LearnController < ApplicationController  
  before_filter :ajax_call, :except => [:filepanel, :autotest, :file, :terminal, :console, :db]
  skip_before_filter :verify_authenticity_token
  # protect_from_forgery :only => [:retek]
  before_filter :login_required
  
  def index
    @user = current_user
    current_user.start_course
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
    current_user.restart_course
    path = '/learn_course/autotest'
    res = Net::HTTP.get(current_user.course_host, path)

    logger.info("Proxied autotest to backend to #{current_user.course_host + path}.")
    logger.info(res)
    
    header = File.readlines("#{current_user.path}/active/spec/learn_story.html").map{|l| l.rstrip}.to_s
    render :text => header + res
  end

  # Proxied terminal back to backend.
  def terminal
    path = "#{current_user.course_host}/learn_course/terminal"
    begin
      res = Net::HTTP.post_form(URI.parse(path),{'command' => params[:command]}).body
    rescue StandardError => e
      res = e.message
    end
    logger.info("Proxied terminal command to backend to #{path}.")
    logger.info(res)
    render :text => res
  end

  # Proxied app console back to backend
  def console
    path = "#{current_user.course_host}/learn_course/console"
    begin
      res = Net::HTTP.post_form(URI.parse(path),{'command' => params[:command]}).body
    rescue StandardError => e
      res = e.message
    end
    logger.info("Proxied app console command to backend to #{path}.")
    logger.info(res)
    render :text => res
  end
  
  # Proxied db console back to backend
  def db
    path = "#{current_user.course_host}/learn_course/db"
    begin
      res = Net::HTTP.post_form(URI.parse(path),{'command' => params[:command]}).body
    rescue StandardError => e
      res = e.message
    end
    logger.info("Proxied db console command to backend to #{path}.")
    logger.info(res)
    render :text => res
  end
  
  def file
    baseDir = ""
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
    baseDir = ""
    
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
  
  
  private
  def ajax_call
    if request.xhr?
      render :layout =>false
    end
    return true
  end
end

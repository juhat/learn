# require 'rubygems'
require 'spec'
require 'hpricot'
require 'net/http'
require 'uri'

class LearnController < ApplicationController  
  before_filter :ajax_call, :except => [:filepanel, :autotest, :file, :terminal, :console, :db]
  skip_before_filter :verify_authenticity_token
  # protect_from_forgery :only => [:retek]  
  
  def index
    render :layout=>'learn'
  end

  def restart
    # `tar czvf testproject_bak/#{Time.now.strftime("%y%m%d%H%M%S")}.tar.gz testproject/`
    `rm -rf testproject`
    `cp -R testproject_skel testproject`
    `cp spec/learn_gallery_spec.rb testproject/spec/learn_gallery_spec.rb`
    `cp spec/spec.opts testproject/spec/spec.opts`
    `cp spec/spec_helper.rb testproject/spec/spec_helper.rb`
    `cp spec/learn_story.html testproject/spec/learn_story.html`
    `cp app/controllers/learn_course_controller.rb testproject/app/controllers/learn_course_controller.rb`
    `cd testproject && script/generate controller gallery`
    `touch testproject/tmp/restart.txt`
    `touch tmp/restart.txt`
    redirect_to :controller => :learn
  end
  
  # Proxied back to backend.
  # TODO: Restarting of backend is not the best deal, it is a workaround.
  # It just needid because the backend code is cached even in development mode.
  def autotest
    logger.info('Proxied autotest to backend.')
    `touch testproject/tmp/restart.txt`
    doc = Hpricot(Net::HTTP.get('user.atti.la', '/learn_course/autotest'))

    (doc/".not_implemented_spec_name").each{|e| e.inner_html = e.inner_html[0,e.inner_html.index('(')] }
    (doc/".backtrace").each{|e| e.inner_html = ''}
    (doc/"pre code").each{|e| e.inner_html = ''}
    (doc/".failure").each{|e| e.inner_html = ''}
    
    header = File.readlines("#{RAILS_ROOT}/testproject/spec/learn_story.html").map{|l| l.rstrip}.to_s
    render :text => header + (doc/".results").to_s
  end

  # Proxied terminal back to backend.
  def terminal
    logger.info('Proxied terminal to backend.')
    res = Net::HTTP.post_form(URI.parse('http://user.atti.la/learn_course/terminal'),{'command' => params[:command]})
    render :text => res.body
  end

  # Proxied app console back to backend
  def console
    logger.info('Proxied app console to backend.')
    res = Net::HTTP.post_form(URI.parse('http://user.atti.la/learn_course/console'),{'command' => params[:command]})
    render :text => res.body
  end
  
  # Proxied db console back to backend
  def db
    logger.info('Proxied db console to backend.')
    res = Net::HTTP.post_form(URI.parse('http://user.atti.la/learn_course/db'),{'command' => params[:command]})
    render :text => res.body
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

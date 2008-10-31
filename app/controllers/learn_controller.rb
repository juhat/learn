# require 'rubygems'
require 'hpricot'

class LearnController < ApplicationController  
  before_filter :ajax_call, :except => [:filepanel, :autotest, :file]
  protect_from_forgery :only => [:retek]  
  
  def index
    render :layout=>'learn'
  end
  
  def autotest
    doc =  Hpricot( `script/spec -o spec/spec.opts spec/learn_test_spec.rb` )
    render :text => (doc/".results").inner_html
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
    t = Thread.new { `cd testproject && #{params[:command]}` }
    tval = t.value
    t.exit! 
    render :text=>tval
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

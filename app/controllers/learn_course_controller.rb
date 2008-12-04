# This controller will be copied to the new testproject.
# It will provide the feedback to the LEARN environment.
# This separation help us to separate code and programs by rights.

require 'spec'
class LearnCourseController < ApplicationController
  skip_before_filter :verify_authenticity_token
  session :off
  
  def autotest
    # ::ActionController::Dispatcher.reload_application() 
    logger.info('Working on autotest proxied by frontend.')
    out, err = StringIO.new('',"w+"), StringIO.new('',"w+")
    ::Spec::Runner::CommandLine.run(::Spec::Runner::OptionParser.parse(["#{RAILS_ROOT}/spec/learn_gallery_spec.rb",'-f html','-t 10','-c'], err, out))
    render :text => out.string
  end  
  
  def terminal
    logger.info('Working on terminal command proxied by frontend.')
    t = Thread.new { `#{params[:command]}` }
    tval = t.value
    t.exit!
    render :text=>tval
  end
  
  def console
    logger.info('Working on app console command proxied by frontend.')
    result = nil
    begin
      result = eval(params[:command])
    rescue Exception => ex
      result = ex.to_s
    end
    render :text=> result
  end
  
  def db
    begin
      some_objects = []
      mysql_res = ActiveRecord::Base.connection.execute(params[:command])
      mysql_res.each{ |res| some_objects << res }
    rescue Exception => e
      some_objects = e.message
    end
    render :text => some_objects.to_yaml
  end
end
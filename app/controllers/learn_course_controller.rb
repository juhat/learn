# This controller will be copied to the new testproject.
# It will provide the feedback to the LEARN environment.
# This separation help us to separate code and programs by rights.

require 'spec'

class AuditLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{msg} | #{severity}:#{timestamp.to_formatted_s(:db)}\n" 
  end 
end

class LearnCourseController < ApplicationController
  skip_before_filter :verify_authenticity_token
  session :off
  @@learn_logger = AuditLogger.new("#{RAILS_ROOT}/log/learn.log")
  
  def autotest
    # Dir.glob(File.join(RAILS_ROOT, '/app/controllers/*.rb')).each {|f| require f unless f.include?('learn_course') or f.include?('application')}    

    logger.info('Working on autotest proxied by frontend.')
    out, err = StringIO.new('',"w+"), StringIO.new('',"w+")
    ::Spec::Runner::CommandLine.run(::Spec::Runner::OptionParser.parse(["#{RAILS_ROOT}/spec/learn_gallery_spec.rb",'-f html','-t 10','-c'], err, out))
    render :text => out.string
  end  
  
  def terminal
    logger.info('Working on terminal command proxied by frontend.')
    @@learn_logger.info("Terminal command: #{params[:command]}")
    t = Thread.new { `#{params[:command]}` }
    tval = t.value
    t.exit!
    render :text=>tval
  end
  
  def console
    logger.info('Working on app console command proxied by frontend.')
    @@learn_logger.info("App console command: #{params[:command]}")
    result = nil
    begin
      result = eval(params[:command])
    rescue Exception => ex
      result = ex.to_s
    end
    render :text=> result
  end
  
  def db
    logger.info('Working on db console command proxied by frontend.')
    @@learn_logger.info("Db console command: #{params[:command]}")
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
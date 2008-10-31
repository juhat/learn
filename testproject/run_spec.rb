#!/usr/bin/env ruby
# $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../vendor/plugins/rspec/lib"))
require 'rubygems'
require 'spec'

out = ''
if File.exist?(File.dirname(__FILE__) + '/app/controllers/page_controller.rb')
  out += `script/spec spec/controllers/page_controller_spec.rb -o spec/spec.opts`
else
  out += 'Create a PageController!'
end
puts '//'
puts out
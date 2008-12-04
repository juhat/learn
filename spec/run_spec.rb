require 'rubygems'
require 'spec'
out, err = StringIO.new('',"w+"), StringIO.new('',"w+")
::Spec::Runner::CommandLine.run(::Spec::Runner::OptionParser.parse(['sample_spec.rb','-f html','-t 10','-c'], err, out))
puts out.string
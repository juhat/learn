require File.join(File.dirname(__FILE__), 'spec_helper.rb')

class LibnssMysqlManifest < Moonshine::Manifest
  plugin :libnss_mysql
end

describe "A manifest with the LibnssMysql plugin" do
  
  before do
    @manifest = LibnssMysqlManifest.new
    @manifest.libnss_mysql
  end
  
  it "should be executable" do
    @manifest.should be_executable
  end
  
  #it "should provide packages/services/files" do
  # @manifest.packages.keys.should include 'foo'
  # @manifest.files['/etc/foo.conf'].content.should match /foo=true/
  # @manifest.execs['newaliases'].refreshonly.should be_true
  #end
  
end
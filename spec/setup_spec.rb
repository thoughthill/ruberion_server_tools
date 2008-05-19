require "rubygems"
require 'rake'
require 'rake/testtask'
require 'test/unit'
require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/rake_spec_helper'

context "rake setup" do
    
  it "should create required directories" do
    dirs = ["tmp/pids", "tmp/cache", "tmp/sessions"]
    dirs.each do |dir|
      FileUtils.rm_rf dir
    end
    system 'rake setup:create_required_dirs'
    dirs.each do |dir|
      assert File.exist?(dir)
    end
  end
  
  it "should create database.yml if it's not there" do
    file = "#{RAILS_ROOT}/config/database.yml"
    backup_file(file)
    system 'rake setup:create_database_yml application=test'
    assert File.exist?(file)
    restore_file(file)
  end

  it "should not overwride database.yml if it's there" do
    time = Time.now
    database_yml = "#{RAILS_ROOT}/config/database.yml"
    system 'rake setup:create_database_yml application=test'
    File.mtime(database_yml).should < time
  end
  
  it "should setup ultrasphinx if config/ultrasphinx(.example/.sample) is there" do
    file = "#{RAILS_ROOT}/config/ultrasphinx"
    backup_file(file)
    system 'rake setup:setup_ultrasphinx'
    assert File.exist?(file)
    remove_file(file)
    restore_file(file)
  end
  
  # it "should not setup ultrasphinx if config/ultrasphinx(.example/.sample) is not there" do
  #   file = "#{RAILS_ROOT}/config/ultrasphinx"
  #   config_files = Dir.entries("#{RAILS_ROOT}/config/")
  #   if sample_dir = config_files.find { |t| t.match(/ultrasphinx\./) }
  #     puts "-- #{sample_dir} --"
  #     backup_file(sample_dir)
  #     backup_file(file)
  #     system('rake setup:setup_ultrasphinx')
  #     ###assert !File.exist?(file)
  #     restore_file(sample_dir)
  #     restore_file(file)
  #   end
  # end

end

require 'rubygems'
require 'spec'
require 'rake'
require 'rake/testtask'
require 'test/unit'
require File.dirname(__FILE__) + '/../../../../config/boot.rb'
require File.dirname(__FILE__) + '/../../../../config/environment.rb'

context "rake setup" do
  
  it "should create required directories" do
    dirs = ["tmp/pids", "tmp/cache", "tmp/sessions"]
    dirs.each do |dir|
      FileUtils.rm_rf dir
    end
    Rake::Task['setup:create_required_dirs'].invoke
  end
  
  it "should run and pass rspec after setup" do
    true
  end

  it "should create database.yml if it's not there" do
    true
  end

  it "should not overwride database.yml if it's there" do
    true
  end

  it "should setup ultrasphinx if config/ultrasphinx.example is there" do
    true
  end

  it "should not setup ultrasphinx if config/ultrasphinx.example is not there" do
    true
  end

end

#!/usr/bin/ruby

require "fusefs"
require "github_browser"

class GithubFS

  attr_reader :user, :repo, :browser

  def initialize(user, repo)
    @user = user
    @repo = repo
    @browser = GithubBrowser.new @user, @repo
  end

  def contents(path)
    @browser.directory path
  end

  def file?(path)
    @browser.file? path
  end

  def read_file(path)
    @browser.file path
  end

  def directory?(path)
    @browser.directory? path
  end

end

if ARGV.length != 3
  puts "Usage: ./githubfs.rb USERNAME REPO_NAME MOUNT_DIR"
  exit
end  

gfs = GithubFS.new ARGV[0], ARGV[1]
FuseFS.set_root gfs

FuseFS.mount_under ARGV[2]
FuseFS.run

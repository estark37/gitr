#!/usr/bin/ruby

require "fusefs"
require "github_browser"

class GithubFS

  attr_reader :user, :repo, :browser, :ref, :ref_file

  def initialize(user, repo)
    @user = user
    @repo = repo

    @ref_file = "/.ref"

    @browser = GithubBrowser.new @user, @repo

  end

  def contents(path)
    @browser.directory path
  end

  def file?(path)
    (path == @ref_file) ? true : (@browser.file? path)
  end

  def read_file(path)
    (path == @ref_file) ? @browser.ref : (@browser.file path)
  end

  def directory?(path)
    @browser.directory? path
  end

  def can_write?(path)
    (path == @ref_file) ? true : false
  end

  def can_delete?(path)
    (path == @ref_file) ? true : false
  end

  def write_to(path, contents)
    return false unless path == @ref_file
    @browser.ref = contents
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

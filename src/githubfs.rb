#!/usr/bin/ruby

require "fusefs"
require "github_browser"

class GithubFS

  attr_reader :user, :repo, :browser, :ref, :ref_file

  def initialize(user, repo)
    @user = user
    @repo = repo

    @ref_file = "/.ref"
    @user_file = "/.user"
    @repo_file = "/.repo"

    @browser = GithubBrowser.new @user, @repo

    # initialize caches
    @contents_cache = {}
    @is_file_cache = {}
    @file_cache = {}
    @is_directory_cache = {}

  end

  def contents(path)
    if @contents_cache[path]
      @contents_cache[path]
    else
      @contents_cache[path] = @browser.directory path
      @contents_cache[path]
    end
  end

  def file?(path)
    if @is_file_cache[path]
      @is_file_cache[path]
    end

    case
    when ([@ref_file, @user_file, @repo_file].include? path)
      @is_file_cache[path] = true
    else
      @is_file_cache[path] = @browser.file? path
    end

    @is_file_cache[path]
  end

  def read_file(path)
    if @file_cache[path]
      @file_cache[path]
    end

    case
    when path == @ref_file
      @file_cache[path] = @browser.ref
    when path == @user_file
      @file_cache[path] = @user
    when path == @repo_file
      @file_cache[path] = @repo
    else
      @file_cache[path] = @browser.file path
    end

    @file_cache[path]
  end

  def directory?(path)
    if @is_directory_cache[path]
      @is_directory_cache[path]
    end

    @is_directory_cache[path] = @browser.directory? path
    @is_directory_cache[path]
  end

  def can_write?(path)
    (path == @ref_file) ? true : false
  end

  def can_delete?(path)
    (path == @ref_file) ? true : false
  end

  def write_to(path, contents)
    return false unless path == @ref_file
    clear_caches
    @browser.ref = contents.strip
    return true
  end

  private
  
  def clear_caches()
    @contents_cache = {}
    @is_file_cache = {}
    @file_cache = {}
    @is_directory_cache = {}
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

#!/usr/bin/ruby

require "github_browser"

class Gitr

  attr_reader :user, :repo, :browser, :ref

  def initialize(root)
    @user_file = File.join(root, "/.user")
    read_user
    @repo_file = File.join(root, "/.repo")
    read_repo
    @ref_file = File.join(root, "/.ref")
    read_ref
    @browser = GithubBrowser.new @user, @repo, @ref
    
  end

  def checkout(ref)
    @browser.ref = ref
    write_ref
  end

  private

  ref_file = "/.ref"
  
  def write_ref
    File.open(@ref_file, 'w') do |f|
      f.puts @browser.ref
    end
  end

  def read_ref
    File.open(@ref_file, 'r') do |f|
      @ref = f.gets
    end
  end

  def read_user
    File.open(@user_file, 'r') do |f|
      @user = f.gets
    end
  end

  def read_repo
    File.open(@repo_file, 'r') do |f|
      @repo = f.gets
    end
  end

end

if ARGV.length < 2
  puts "Usage: ./gitr.rb GITHUBFS_ROOT COMMAND"
  exit
end

gitr = Gitr.new ARGV[0]

cmd = ARGV[1]

case
when cmd == "checkout"
  if ARGV.length < 3
    puts "Usage: ./gitr.rb GITHUBFS_ROOT checkout COMMIT"
    exit
  end

  gitr.checkout ARGV[2]

else
  puts "unknown command"
end

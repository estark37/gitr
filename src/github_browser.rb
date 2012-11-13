#!/usr/bin/ruby

require "rubygems"
require "highline/import"
require "base64"

require "github_connection"

# Implements file system operations by making requests to a
# GithubConnection.

class GithubBrowser

  attr_reader :user, :repo
  attr_accessor :ref

  def initialize(user, repo, ref = "master")
    @conn = GithubConnection.new
    @user = user
    @repo = repo
    @ref = ref    
  end

  def directory(path = "/")
    @conn.contents(@user, @repo, path, @ref).map { |entry| entry["name"] }
  end

  def directory?(path)
    begin
      contents = @conn.contents(@user, @repo, path, @ref)
      contents.instance_of? Array
    rescue
      false
    end
  end    

  def file(path = "")
    f = @conn.contents(@user, @repo, path, @ref)
    contents = f['content']
    Base64.decode64(contents)
  end

  def file?(path)
    begin
      f = @conn.contents(@user, @repo, path, @ref)
      f["type"] == "file"
    rescue
      false
    end
  end 

end
        

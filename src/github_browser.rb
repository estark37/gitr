#!/usr/bin/ruby

require "base64"

require "github_connection"

# Encapsulates a GithubConnection and provides higher-level methods like
# reading the contents of a file.

class GithubBrowser

  attr_accessor :user, :repo
  attr_reader :ref # will be attr_accessor later

  def initialize(user, repo)
    @conn = GithubConnection.new
    @user = user
    @repo = repo
    @ref = "master"
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
        

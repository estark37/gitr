#!/usr/bin/ruby

require "rubygems"
require "httpclient"
require "json"
require "base64"

# Sends Github API requests and returns JSON responses

class GithubConnection

  attr_accessor :clt

  BASE_URL = "https://api.github.com"

  def initialize
    @clt = HTTPClient.new
    setup_auth
  end

  def contents(user, repo, path = "/", ref = "master")
    url = make_url("repos/#{user}/#{repo}/contents#{path}?ref=#{ref}")
    resp = request("GET", url)
    return JSON.parse(resp.body)
  end

  private

  def setup_auth
    puts "Github username: "
    username = $stdin.gets().chomp

    def get_pwd(prompt = "Github password: ")
      ask(prompt) { |q| q.echo = false }
    end
    pwd = get_pwd()

    @token = get_existing_token(username, pwd) ||
      create_token(username, pwd)
  end

  def get_existing_token(username, password)
    resp = authorizations_request("GET", username, password)
    resp.each do |authorization|
      if authorization["note"] == "gitr token"
        return authorization["token"]
      end
    end

    return ""
  end

  def create_token(username, password)
    data = {
      "scopes" => ["public_repo"],
      "note" => "gitr token"
    }
    resp = authorizations_request("POST", username, password, data)
    return resp["token"]
  end

  def authorizations_request(method, username, password, data = {})
    auth_str = Base64.encode64("#{username}:#{password}").chomp
    auth_hdr = {
      "Authorization" => "Basic #{auth_str}"
    }

    url = make_url("authorizations")
    resp = request(method, url, data, auth_hdr)
    return JSON.parse(resp.body)
  end

  def make_url(path)
    "#{BASE_URL}/#{path}"    
  end

  def request(verb, url, data = {}, hdr = {})
    if verb == "GET"
      method = :get
    elsif verb == "POST"
      method = :post
    end

    if @token
      hdr["Authorization"] = "token #{@token}"
    end

    resp = @clt.send(method, url, JSON.dump(data), hdr)
    return resp
  end

end

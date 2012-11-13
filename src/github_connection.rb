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
  end

  def contents(user, repo, path = "/", ref = "master")
    url = make_url("repos/#{user}/#{repo}/contents#{path}?ref=#{ref}")
    resp = request("GET", url)
    return JSON.parse(resp.body)
  end

  private

  def make_url(path)
    "#{BASE_URL}/#{path}"
  end

  def request(verb, url, data = {})
    if verb == "GET"
      resp = @clt.get url
    elsif verb == "POST"
      resp= @clt.post url data
    end
    return resp
  end

end

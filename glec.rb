# glec
# Github Latest Event Checker
#

require 'optparse'
require 'net/https'
require 'uri'

module Glec
  # GithubのAPIを呼び出し、結果を返す
  def self.get_events(owner: , repo: )
    url = "https://api.github.com/repos/#{owner}/#{repo}/events"

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)

    case response
    when Net::HTTPOK
      return response.body
    else
      raise "#{response.code} : #{response.msg}"
    end
  end

  # メインの処理
  module Main
    DEFAULT_OWNER = 'jz4o'
    DEFAULT_REPO  = 'glec'

    params = ARGV.getopts(
      '',
      "owner:#{DEFAULT_OWNER}",
      "repo:#{DEFAULT_REPO}"
    ).map{ |k,v| [k.to_sym, v] }.to_h

    begin
      puts Glec.get_events(params)
    rescue => e
      puts e.message
    end
  end
end


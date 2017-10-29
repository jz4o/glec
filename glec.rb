# glec
# Github Latest Event Checker
#

require 'net/https'
require 'uri'
require 'json'

# Githubの任意のリポジトリから最新のEventを取得する
module Glec
  TARGET_ALL    = 'all'.freeze
  DEFAULT_OWNER = 'jz4o'.freeze
  DEFAULT_REPO  = 'glec'.freeze
  DEFAULT_USER  = TARGET_ALL
  DEFAULT_TYPE  = TARGET_ALL

  # メインの処理
  def self.start(params)
    repo_data = params.select { |key| %i[owner repo].include? key }

    events = get_events(repo_data)
    events_array = JSON.parse events

    events_array = refine_by_user(events_array, params[:user])
    events_array = refine_by_type(events_array, params[:type])
    latest_event = get_latest_event(events_array)
    latest_event['created_at']
  rescue RuntimeError => e
    puts e.message
  end

  # GithubのAPIを呼び出し、結果を返す
  def self.get_events(owner:, repo:)
    url = "https://api.github.com/repos/#{owner}/#{repo}/events"

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)

    access_token = ENV['GITHUB_API_ACCESS_TOKEN']
    request['Authorization'] = "token #{access_token}" if access_token

    response = http.request(request)

    case response
    when Net::HTTPOK
      return response.body
    else
      raise "#{response.code} : #{response.msg}"
    end
  end
  private_class_method :get_events

  def self.refine_by_user(array, user)
    array ||= []

    unless user.eql? TARGET_ALL
      array.select! { |event| event['actor']['login'].eql? user }
    end

    array
  end
  private_class_method :refine_by_user

  def self.refine_by_type(array, type)
    array ||= []

    unless type.eql? TARGET_ALL
      array.select! { |event| event['type'] =~ /#{type}/i }
    end

    array
  end
  private_class_method :refine_by_type

  def self.get_latest_event(events)
    events ||= []
    events.first || {}
  end
  private_class_method :get_latest_event
end

# glec
# Github Latest Event Checker
#

require 'net/https'
require 'uri'
require 'json'

Glec = Module.new do
  TARGET_ALL    = 'all'
  DEFAULT_OWNER = 'jz4o'
  DEFAULT_REPO  = 'glec'
  DEFAULT_USER  = TARGET_ALL
  DEFAULT_TYPE  = TARGET_ALL

  class Object
    def introduce
      puts self.inspect
    end
  end

  class String
    def to_array_of_hash
      JSON.parse(self)
    end
  end

  class Array
    def refine_by_user(user)
      unless user.eql? TARGET_ALL
        self.select!{ |event| event['actor']['login'].eql? user }
      end

      self
    end

    def refine_by_type(type)
      unless type.eql? TARGET_ALL
        self.select!{ |event| event['type'] =~ /#{type}/i }
      end

      self
    end

    def latest
      first ? first : []
    end
  end

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
  def self.start(params)
    repo_data = params.select{ |key| %i[owner repo].include? key }

    Glec.get_events(repo_data)
      .to_array_of_hash
      .refine_by_user(params[:user])
      .refine_by_type(params[:type])
      .latest
      .introduce
  rescue => e
    puts e.message
  end
end


require "sugoi_pretty_log/version"
require "awesome_print"
require "user_agent_parser"
require "json"

module SugoiPrettyLog
  class Parser
    def initialize(log, options)
      @log = log.strip
      @options = options
      @user_agent_key_name = options[:user_agent].to_s
    end

    def parse
      json = build_json
      unless @user_agent_key_name.empty?
        json['user_agent'] =
          UserAgentParser.parse(json[@user_agent_key_name]).to_s
      end
      json
    end

    def build_json
      unless json?
        raise(JSON::ParserError, 'not json')
      end
      JSON.parse(@log)
    rescue JSON::ParserError
      puts '@@@@ done eval @@@@'
      JSON.parse(eval(@log).to_json)
    end

    def json
    end

    private

    def json?
      /\A{.*}\z/
    end
  end

  def self.parse(log, options)
    Parser.new(log, options).parse
  end
end

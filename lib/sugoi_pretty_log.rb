require "sugoi_pretty_log/version"
require "awesome_print"
require "user_agent_parser"
require "json"

module SugoiPrettyLog
  class Parser
    def initialize(log, options)
      @log = log.strip
      @options = options
      @user_agent_key_name = options[:user_agent]
      @hashs_option = options[:hash]
    end

    def parse
      json = build_json
      if @user_agent_key_name
        json['user_agent'] =
          UserAgentParser.parse(json[@user_agent_key_name.to_s]).to_s
      end

      if @hashs_option
        # SugoiPrettyLog.parse(get_log_with_params, hash: { message: :Parameters }, user_agent: :ua)
        @hashs_option.each do |key, options_key_value|
          json[key.to_s].each do |in_key|
            options_key_value.each do |target_key, target_value|
              if target_value.is_a?(Regexp)
                (in_key =~ target_value) || next
                json[target_key] = $1
              end
            end
          end
        end

        # real['messages'][2] =~ /Parameters: (.*)/
      end
      json
    end

    def build_json
      unless json?
        raise(JSON::ParserError, 'not json')
      end
      JSON.parse(@log)
      # 意味ある？
      # rescue JSON::ParserError
      #   puts '@@@@ done eval @@@@'
      #   JSON.parse(eval(@log).to_json)
    end

    private

    # TODO this is injected
    def json?
      /\A{.*}\z/
    end
  end

  def self.parse(log, options = {})
    Parser.new(log, options).parse
  end
end

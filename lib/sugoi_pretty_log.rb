require "sugoi_pretty_log/version"
require "awesome_print"
require "user_agent_parser"
require "json"

module SugoiPrettyLog
  class ParsedMember
    attr_accessor :name, :source
    attr_reader :json_key

    def initialize(json_key)
      @json_key = json_key.to_s
    end
  end

  class HashPaser
    def self.parse(string)
      # TODO more safe
      eval string
    end
  end

  class Parser
    def initialize(log, options)
      @log = log.strip
      @options = options
      @user_agent_key_name = options[:user_agent]
      @hashs_option = options[:hash]
      @parsed_members = []
    end

    def parse
      json = build_json
      parse_user_agent!(json)
      parse_hash!(json)
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

    def parse_hash(json_key: )
      parsed_member = ParsedMember.new(json_key)
      @parsed_members << parsed_member
      yield(parsed_member)
    end

    private

    # TODO security hole
    def json?
      /\A{.*}\z/
    end

    def parse_user_agent!(json)
      if @user_agent_key_name
        json['user_agent'] =
          UserAgentParser.parse(json[@user_agent_key_name.to_s]).to_s
      end
    end

    def parse_hash!(json)
      @parsed_members.each do |parsed_member|
        object = json[parsed_member.json_key]
        case object
        when Array
          object.each do |item|
            (parsed_member.source =~ item) || next
            json[parsed_member.name] = HashPaser.parse($1)
          end
        when String
          (parsed_member.source =~ object) || next
          json[parsed_member.name] = HashPaser.parse($1)
        end
      end
    end
  end

  def self.parse(log, options = {})
    parser = Parser.new(log, options)
    if block_given?
      yield(parser)
    end
    parser.parse
  end
end

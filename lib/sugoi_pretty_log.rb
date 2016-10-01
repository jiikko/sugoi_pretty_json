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
      string.gsub!('=>', ':')
      string.gsub!(/\r\n|\n/, '')
      JSON.parse(string)
    end
  end

  class SugoiJSON
    def initialize(log)
      unless json?
        raise(JSON::ParserError, 'not json')
      end
      @json = JSON.parse(log)
      # 意味ある？
      # rescue JSON::ParserError
      #   puts '@@@@ done eval @@@@'
      #   JSON.parse(eval(@log).to_json)
    end

    def to_hash
      @json
    end

    def parse_user_agent!(user_agent_member)
      if user_agent_member
        @json[user_agent_member.name] =
          UserAgentParser.parse(@json[user_agent_member.json_key]).to_s
      end
    end

    def parse_hash!(parsed_members)
      parsed_members.each do |parsed_member|
        object = @json[parsed_member.json_key]
        case object
        when Array
          object.each do |item|
            (parsed_member.source =~ item) || next
            @json[parsed_member.name] = HashPaser.parse($1)
          end
        when String
          (parsed_member.source =~ object) || next
          @json[parsed_member.name] = HashPaser.parse($1)
        end
      end
    end

    def slice_only_option!(option_only)
      return unless option_only
      @json.each do |key, value|
        @json.delete_if { |key, value| !option_only.include?(key) }
      end
    end

    private

    def json?
      true
    end
  end

  class Parser
    def initialize(log, options)
      @log = log.strip
      if options[:user_agent]
        parse_user_agent(json_key: options[:user_agent])
      end
      @parsed_members = []
      @option_only = options[:only] || []
    end

    def parse
      json = SugoiJSON.new(@log)
      json.parse_user_agent!(@user_agent_member)
      json.parse_hash!(@parsed_members)
      json.slice_only_option!(option_only)
      json.to_hash
    end

    def parse_hash(json_key: )
      parsed_member = ParsedMember.new(json_key)
      yield(parsed_member)
      @parsed_members << parsed_member
    end

    def parse_user_agent(json_key: )
      parsed_member = ParsedMember.new(json_key)
      yield(parsed_member) if block_given?
      parsed_member.name ||= 'user_agent'
      @user_agent_member = parsed_member
    end

    private

    def option_only
      only = []
      only.concat(@option_only)
      only << @user_agent_member.name if @user_agent_member
      @parsed_members.each { |member| only << member.name }
      only
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

require "sugoi_pretty_json/version"
require "sugoi_pretty_json/sugoi_json"
require "awesome_print"
require "user_agent_parser"
require "json"

module SugoiPrettyJSON
  def self.parse(log, options = {})
    parser = Parser.new(log, options)
    if block_given?
      yield(parser)
    end
    parser.parse
  end

  class ParsedMember
    attr_accessor :name, :source
    attr_reader :json_key

    def initialize(json_key)
      @json_key = json_key.to_s
    end
  end

  class Parser
    def initialize(log, options)
      @log = log.strip
      if options[:user_agent]
        parse_user_agent(json_key: options[:user_agent])
      end
      @parsed_hash_members = []
      @parsed_string_members = []
      @assigned_option_only = options[:only] || []
    end

    def parse
      json = SugoiJSON.new(@log)
      json.parse_user_agent!(@user_agent_member)
      json.parse_hash!(@parsed_hash_members)
      json.parse_string!(@parsed_string_members)
      json.slice_only_option!(build_option_only)
      json.to_hash
    end

    def parse_string(json_key: )
      parsed_member = ParsedMember.new(json_key)
      yield(parsed_member)
      @parsed_string_members << parsed_member
    end

    def parse_hash(json_key: )
      parsed_member = ParsedMember.new(json_key)
      yield(parsed_member)
      @parsed_hash_members << parsed_member
    end

    def parse_user_agent(json_key: )
      parsed_member = ParsedMember.new(json_key)
      yield(parsed_member) if block_given?
      parsed_member.name ||= 'user_agent'
      @user_agent_member = parsed_member
    end

    private

    def build_option_only
      return if @assigned_option_only.empty?
      only = []
      only.concat(@assigned_option_only)
      only << @user_agent_member.name if @user_agent_member
      @parsed_hash_members.each { |member| only << member.name }
      only
    end
  end
end

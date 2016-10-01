module SugoiPrettyLog
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
end

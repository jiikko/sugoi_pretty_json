module SugoiPrettyJSON
  class HashPaser
    def self.parse(string)
      string.gsub!('=>', ':')
      string.gsub!(/\r|\n/, '')
      begin
        JSON.parse(string)
      rescue JSON::ParserError
        string
      end
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
        uap = UserAgentParser.parse(@json[user_agent_member.json_key])
        @json[user_agent_member.name] = "#{uap.os} / #{uap}"
      end
    end

    def parse_string!(parsed_members)
      parse(parsed_members, type: :string)
    end

    def parse_hash!(parsed_members)
      parse(parsed_members, type: :hash)
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

    def parse(parsed_members, type: )
      parsed_members.each do |parsed_member|
        object = @json[parsed_member.json_key]
        case object
        when Array
          object.each { |item| set_json(parsed_member, item, @json, type) }
        when String
          set_json(parsed_member, object, @json, type)
        end
      end
    end

    def set_json(parsed_member, object, json, type)
      (parsed_member.source =~ object) || return
      @json[parsed_member.name] = (type == :hash ? HashPaser.parse($1) : $1)
    end
  end
end

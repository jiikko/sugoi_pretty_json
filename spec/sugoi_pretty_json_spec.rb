require "spec_helper"

describe SugoiPrettyJSON do
  it "has a version number" do
    expect(SugoiPrettyJSON::VERSION).not_to be nil
  end

  let(:get_log) do
'{"sid":"d","uid":"","dev":"s","messages":["Started GET  for 127.0.0.1 at 2016-08-07 00:00:06 +0900","Processing by TopController#index as HTML","Completed 200 OK in 50ms (Views: 37.6ms | ActiveRecord: 5.6ms | Solr: 0.0ms)"],"level":"INFO","mt":"GET","pt":"/","ip":"127.0.0.1","ua":"Mozilla/5.0 (Linux; Android 5.0.2; 402SO Build/28.0.C.4.146) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.81 Mobile Safari/537.36","rf":"null"}'
  end

  let(:get_log_with_params) do
'{"sid":"5a4d","uid":"","dev":"s","messages":["Started GET \"/facilities/show_afte\" for 127.0.0.1 at 2016-08-06 23:59:59 +0900","Processing by FacilitiesController#show_after as */*","  Parameters: {\"q\"=>{\"0\"=>{\"id\"=>\"175\", \"type\"=>\"Facility\", \"css\"=>\"c-btn__favorite p-faci__btn__favorite\"}, \"1\"=>{\"id\"=>\"13452\", \"type\"=>\"Experience\"}, \"2\"=>{\"id\"=>\"6387\", \"type\"=>\"Note\", \"css\"=>\"c-btn__favorite\"}, \"3\"=>{\"id\"=>\"5881\", \"type\"=>\"Note\", \"css\"=>\"c-btn__favorite\"}}}","Completed 200 OK in 20ms (Views: 0.3ms | ActiveRecord: 3.7ms | Solr: 0.0ms)"],"level":"INFO","mt":"GET","pt":"/main","ip":"127.0.0.1","ua":"Mozilla/5.0 (Linux; Android 4.1.2; SO-04E Build/10.1.1.D.2.31) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.98 Mobile Safari/537.36","rf":"http://localhost/175"}'
  end

  let(:post_log) do
  end

  describe '#parse' do
    context 'user_agentのparseをしない時' do
      it 'json_key user_agent がないこと' do
        actual = SugoiPrettyJSON.parse(get_log)
        expect(actual['user_agent']).to eq nil
      end
    end
    context 'when has no params' do
      it 'be success' do
        actual = SugoiPrettyJSON.parse(get_log, user_agent: 'ua')
        expect(actual['user_agent']).to eq "Chrome Mobile 51.0.2704.81"
      end
    end

    context 'when has params' do
      it 'be success' do
        actual = SugoiPrettyJSON.parse(get_log_with_params) do |pretty_json|
          pretty_json.parse_user_agent(json_key: 'ua')
          pretty_json.parse_hash(json_key: 'messages') do |p|
            p.name   = 'params'
            p.source = /Parameters: (.*)/m
          end
        end
        ap actual
        expect(actual['user_agent']).to eq "Chrome Mobile 52.0.2743.98"
        expect(actual['params']).to be_a Hash
        expect(actual['sid']).not_to be_nil
      end
    end

    describe 'options' do
      describe 'only' do
        it 'キーがsidだけになっていること' do
          actual = SugoiPrettyJSON.parse(get_log_with_params, only: ['sid'])
          ap actual
          expect(actual.keys.size).to eq 1
          expect(actual['sid']).to be_a String
        end
        it 'キーが2つだけになっていること' do
          actual = SugoiPrettyJSON.parse(get_log_with_params, only: []) do |pretty_json|
            pretty_json.parse_user_agent(json_key: 'ua') do |p|
              p.name   = 'user_agent'
            end
            pretty_json.parse_hash(json_key: 'messages') do |p|
              p.name   = 'params'
              p.source = /Parameters: (.*)/m
            end
          end
          ap actual
          expect(actual['user_agent']).to eq "Chrome Mobile 52.0.2743.98"
          expect(actual['params']).to be_a Hash
          expect(actual.keys.size).to eq 12
          actual = SugoiPrettyJSON.parse(get_log_with_params, only: ['user_agent', 'params']) do |pretty_json|
            pretty_json.parse_user_agent(json_key: 'ua') do |p|
              p.name   = 'user_agent'
            end
            pretty_json.parse_hash(json_key: 'messages') do |p|
              p.name   = 'params'
              p.source = /Parameters: (.*)/m
            end
          end
          ap actual
          expect(actual['user_agent']).to eq "Chrome Mobile 52.0.2743.98"
          expect(actual['params']).to be_a Hash
          expect(actual.keys.size).to eq 2
        end
      end
    end
  end
end

# SugoiPrettyJSON
This gem print pretty log for JSON.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sugoi_pretty_json'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sugoi_pretty_json

## Usage
```ruby
require "sugoi_pretty_json"

log = '{"sid":"5a4d","uid":"","dev":"s","messages":["Started GET \"/facilities/show_afte\" for 127.0.0.1 at 2016-08-06 23:59:59 +0900","Processing by FacilitiesController#show_after as */*","  Parameters: {\"q\"=>{\"0\"=>{\"id\"=>\"175\", \"type\"=>\"Facility\", \"css\"=>\"c-btn__favorite p-faci__btn__favorite\"}, \"1\"=>{\"id\"=>\"13452\", \"type\"=>\"Experience\"}, \"2\"=>{\"id\"=>\"6387\", \"type\"=>\"Note\", \"css\"=>\"c-btn__favorite\"}, \"3\"=>{\"id\"=>\"5881\", \"type\"=>\"Note\", \"css\"=>\"c-btn__favorite\"}}}","Completed 200 OK in 20ms (Views: 0.3ms | ActiveRecord: 3.7ms | Solr: 0.0ms)"],"level":"INFO","mt":"GET","pt":"/main","ip":"127.0.0.1","ua":"Mozilla/5.0 (Linux; Android 4.1.2; SO-04E Build/10.1.1.D.2.31) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.98 Mobile Safari/537.36","rf":"http://localhost/175"}'

hash = SugoiPrettyJSON.parse(log, only: ['user_agent', 'params']) do |pretty_log|
  pretty_log.parse_user_agent(json_key: 'ua') do |p|
    p.name   = 'user_agent'
  end
  pretty_log.parse_hash(json_key: 'messages') do |p|
    p.name   = 'params'
    p.source = /Parameters: (.*)/
  end
end

ap hash
# {
#     "user_agent" => "Chrome Mobile 52.0.2743.98",
#         "params" => {
#         "q" => {
#             "0" => {
#                   "id" => "175",
#                 "type" => "Facility",
#                  "css" => "c-btn__favorite p-faci__btn__favorite"
#             },
#             "1" => {
#                   "id" => "13452",
#                 "type" => "Experience"
#             },
#             "2" => {
#                   "id" => "6387",
#                 "type" => "Note",
#                  "css" => "c-btn__favorite"
#             },
#             "3" => {
#                   "id" => "5881",
#                 "type" => "Note",
#                  "css" => "c-btn__favorite"
#             }
#         }
#     }
# }
```

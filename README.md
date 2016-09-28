# SugoiPrettyPrintLog
This gem print pretty log.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sugoi_pretty_print_log'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sugoi_pretty_print_log

## Usage
```
log = '{"sid":"d","uid":"","dev":"s","messages":["Started GET \"/\" for 127.0.0.1 at 2016-08-07 00:00:06 +0900","Processing by TopController#index as HTML","Completed 200 OK in 50ms (Views: 37.6ms | ActiveRecord: 5.6ms | Solr: 0.0ms)"],"level":"INFO","mt":"GET","pt":"/","ip":"127.0.0.1","ua":"Mozilla/5.0 (Linux; Android 5.0.2; 402SO Build/28.0.C.4.146) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.81 Mobile Safari/537.36","rf":'null'}'
print_log = SugoiPrettyPrintLog.new(log, json: [:Parameters])
print_log.print
```

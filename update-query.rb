require 'dogapi'
require 'json'

# Keys can be found here https://app.datadoghq.com/account/settings#api
api_key=''
app_key=''

dog = Dogapi::Client.new(api_key, app_key)

monitor_name_pattern = /Project Name/
partial_query_pattern = /avg(foo)/
partial_query_replacement = 'avg(bar)'

# Get all monitors
monitors = dog.get_all_monitors()[1]

# Get all monitors with the name Tempo Internal or Tempo to Titan
project_monitors = monitors.keep_if { |monitor| monitor["name"] =~ monitor_name_pattern}

# Find all monitors that have environment:production
monitors_to_update = project_monitors.keep_if { |monitor| monitor["query"] =~ /avg(foo)/}

# Save the monitors to folder before updating as a backup
File.open("original-monitors.json","w") do |f|
  f.write(JSON.pretty_generate(monitors_to_update))
end

# Update the query string to environment:prod instead
updated_monitors = monitors_to_update.each { |monitor| monitor["query"] = monitor["query"].gsub(partial_query_pattern, partial_query_replacement) }

# puts out the name of each monitor you are updating
updated_monitors.each { |monitor| puts(monitor["name"])}

# Finally uncomment and update the monitors
# updated_monitors.each { |monitor| dog.update_monitor(monitor["id"], monitor["query"])}


# Datadogs API returns an array of these
# {"tags"=>[],
# "deleted"=>nil,
# "query"=>"avg(foo)",
# "message"=>"Requests are running slowly.\n@slack-foo",
# "matching_downtimes"=>[],
# "id"=>1044573,
# "multi"=>false,
# "name"=>"Some Name",
# "created"=>"2016-10-26T14:58:01.938284+00:00",
# "created_at"=>1477493881000,
# "creator"=>{"id"=>235521,
# "handle"=>"foo@barr.com",
# "name"=>"Foo Bar",
# "email"=>"foo@barr.com"},
# "org_id"=>40852,
# "modified"=>"2017-01-04T19:27:59.797420+00:00",
# "overall_state"=>"OK",
# "type"=>"query alert",
# "options"=>{"notify_audit"=>false,
# "locked"=>false,
# "timeout_h"=>0,
# "silenced"=>{},
# "thresholds"=>{"critical"=>3000.0,
# "warning"=>2000.0},
# "require_full_window"=>true,
# "new_host_delay"=>300,
# "notify_no_data"=>false,
# "renotify_interval"=>0,
# "no_data_timeframe"=>2}
# }

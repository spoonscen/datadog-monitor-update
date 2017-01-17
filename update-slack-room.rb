require 'dogapi'
require 'json'

# Keys can be found here https://app.datadoghq.com/account/settings#api
api_key=''
app_key=''

dog = Dogapi::Client.new(api_key, app_key)

old_slack_room_pattern = /@slack-foo/
new_slack_room = '@slack-bar'

# Get all monitors
monitors = dog.get_all_monitors()[1]

# Find all monitors that have your old slack room
monitors_to_update = monitors.keep_if { |monitor| monitor["message"] =~ old_slack_room_pattern}

# Save the monitors to folder before updating as a backup
File.open("original-monitors.json","w") do |f|
  f.write(JSON.pretty_generate(monitors_to_update))
end

# Update the message string
updated_monitors = monitors_to_update.each { |monitor| monitor["message"] = monitor["message"].gsub(old_slack_room_pattern, new_slack_room) }

# Save the updated monitors to examine before running the update
File.open("updated-monitors.json","w") do |f|
  f.write(JSON.pretty_generate(updated_monitors))
end

# puts out the name of each monitor you are updating
updated_monitors.each { |monitor| puts(monitor["name"])}

# Finally uncomment this update the monitors
# updated_monitors.each { |monitor| dog.update_monitor(monitor["id"], monitor["query"], :message => monitor["message"])}


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

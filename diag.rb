require_relative "config/environment"
Job.all.each do |job|
  puts "#{job.name}: def=#{job[:definition].class} val=#{job[:definition][0..50] rescue 'ERR'}"
end

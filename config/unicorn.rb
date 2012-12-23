worker_processes 4
timeout 30
preload_app true

@resque_pid = nil
@resque_schedule_pid = nil
@resque_web_pid = nil

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end

  @resque_pid ||= spawn("bundle exec rake " + \
  "resque:work QUEUES=*")

  @resque_schedule_pid ||= spawn("bundle exec rake " + \
  "resque:scheduler")
  @resque_web_pid ||= spawn("resque-web")
end

after_fork do |server, worker|
  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end
end

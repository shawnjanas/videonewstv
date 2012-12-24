unless ENV['RAILS_ENV'] == 'test'
  require 'resque/server'
  require 'resque_scheduler'

  # make sure the RAILS_ENV variable is set so the
  # resque-scheduler can load our scheduled jobs
  # See https://github.com/bvandenbos/resque-scheduler/issues/116
  ENV['RAILS_ENV'] = Rails.env

  # Taken from https://github.com/defunkt/resque
  # http://blog.redistogo.com/2010/07/26/resque-with-redis-to-go/
  rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
  rails_env = ENV['RAILS_ENV'] || 'development'


  resque_config = YAML.load_file(rails_root + '/config/resque.yml')
  Resque.redis = resque_config[rails_env]

  Dir["#{Rails.root}/lib/jobs/*.rb"].each { |file| require file }

  # Load Resque schedule
  # http://blog.redistogo.com/2010/08/05/resque-scheduler/
  Resque.schedule = YAML.load_file(rails_root + '/config/resque_schedule.yml')

  # Authentication for ResqueServer
  # Based on https://gist.github.com/1060167
  if rails_env != 'development'
    Resque::Server.use(Rack::Auth::Basic) do |username, password|
      [username, password] == ["videonewstv", "asdf4321"]
    end
  end
end

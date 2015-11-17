port = ENV['UNICORN_PORT'] || 3000

worker_processes 2
timeout 20
preload_app true

logger Logger.new(STDOUT).tap { |l| l.level = Logger::DEBUG }
listen "[::]:#{port}", backlog: 1

# include necessary dependencies (try local first, then system-wide)
begin
    require "./bundle/bundler/setup"
    require "bundler"
    Bundler.require
rescue LoadError
    require "bundler"
    Bundler.setup
    Bundler.require
end

# set up logging when in proudction mode
if ENV["RACK_ENV"] == "production"
    log = File.new("sinatra.log", "a")
    STDERR.reopen(log)
end

# create the git repository if it doesn't already exist
begin
    system("git", "init", "./pages") unless File.exists?("./pages/.git")
rescue
    abort "Could not find or create git repository"
end

# run our application
require "./controller"
run Wiki::Application


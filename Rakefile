ENV['RACK_ENV'] ||= ENV['RAILS_ENV']
require_relative 'autoconfirm'

begin
  require "rspec/core/rake_task"

  desc "Run all specs"
  task :spec do
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.rspec_opts = %w{--colour --format progress}
      t.pattern = 'spec/**/*_spec.rb'
    end
  end
  task :default => [:spec]
rescue LoadError
  STDERR.puts "Could not load RSpec. On producton that's ok."
end




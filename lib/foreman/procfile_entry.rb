require "foreman"

class Foreman::ProcfileEntry

  attr_reader :name
  attr_reader :command
  attr_accessor :color
  attr_reader :dependent_procfile_entry

  def initialize(name, command, dependent_procfile_entry = nil)
    @name = name
    @command = command
    @dependent_procfile_entry = dependent_procfile_entry
  end

  def spawn(num, pipe, basedir, environment, base_port)
    (1..num).to_a.map do |n|
      process = Foreman::Process.new(self, n, base_port + (n-1), dependency_delay)
      process.run(pipe, basedir, environment)
      process
    end
  end
  
  def dependency_delay
    # give our dependent process 5 seconds to get started
    dependent_procfile_entry ? 5 + dependent_procfile_entry.dependency_delay : 0
  end

end

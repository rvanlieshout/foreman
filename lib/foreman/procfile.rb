require "foreman"
require "foreman/procfile_entry"

# A valid Procfile entry is captured by this regex.
# All other lines are ignored.
#
# /^((\|\s)*)([A-Za-z0-9_]+):\s*(.+)$/
#
# $1 = dependency information
# $2 = name
# $3 = command
#
class Foreman::Procfile

  attr_reader :entries

  def initialize(filename)
    @entries = parse_procfile(filename)
  end

  def [](name)
    entries.detect { |entry| entry.name == name }
  end

  def process_names
    entries.map(&:name)
  end

private

  def parse_procfile(filename)
    dependency_tree = []
    
    File.read(filename).split("\n").map do |line|
      if line =~ /^((\|\s)*)([A-Za-z0-9_]+):\s*(.+)$/
        name = $3
        command = $4

        dependency_level = $1.to_s.scan("|").length
        dependent_procfile_entry = dependency_level > 0 ? dependency_tree[dependency_level - 1] : nil

        Foreman::ProcfileEntry.new(name, command, dependent_procfile_entry).tap do |procfile_entry|
          dependency_tree[dependency_level] = procfile_entry
        end
      end
    end.compact
  end

end

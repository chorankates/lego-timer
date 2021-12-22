#!/bin/env ruby
## lego-build-time.rb -

require 'json'
require 'pry'
require 'yaml'


class Build

  attr_reader :filename, :meta, :times
  def initialize(filename)
    log(sprintf('inspecting[%s]', filename))
    # TODO some error checking here
    @filename = filename
    yaml      = YAML.load_file(@filename)
    @meta     = yaml[:meta]
    @times    = yaml[:times].collect { |c| self.float2time(c) }
  end

  def summarize
    r = {
      :total_time     => duration(get_total()),
      :total_segments => @times.size + 1, # 0 based size
      :average_time   => duration(get_average()),
      :fastest_time   => duration(@times.min),
      :slowest_time   => duration(@times.max),
    }

    # TODO we actually want these first in the output
    [ :title, :url, :date].each do |k|
      r[k] = @meta[k] unless @meta[k].nil?
    end

    r.each do |k,v|
      puts sprintf('%s%s=>%15s', k, ' ' * (15 - k.size), v)
    end
  end

  # really float to seconds
  def float2time(f)
    c = sprintf('%.2f', f)
    t = c.split('.')
    t.first.to_i * 60 + t.last.to_i
  end

  def get_average()
    c = get_total()

    # TODO mean/median/mode ?
    sprintf('%.2f', (c / @times.size.to_f)).to_f
  end

  def get_total()
    r = 0
    @times.each { |c| r += c }

    r
  end

  # seconds to H/M/S duration
  def duration(s)
    # h/t https://gist.github.com/shunchu/3175001
    Time.at(s).utc.strftime('%Hh %Mm %Ss')
  end

end

def log(message, level = :debug)
  puts sprintf('[%s] [%5s] %s', Time.now.strftime('%H:%M.%S'), level.to_s.upcase!, message)
  exit(1) if level.eql?(:fatal)
end

input = ARGV.last
input = './builds' if input.nil?

log(sprintf('using[%s] as input..', input))

if File.file?(input)
  b = Build.new(input)
  b.summarize
elsif File.directory?(input)
  Dir.glob(sprintf('%s/*.yaml', input)).sort.each do |f|
    b = Build.new(f)
    b.summarize
  end
else
  log(sprintf('provided[%s] is neither dir nor file, bailing out', input), :fatal)
end


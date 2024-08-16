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

    c = get_total()

    average = {
      :mean   => duration(get_mean(c)),
      :median => duration(get_median(c)),
      :mode   => duration(get_mode(c)),
    }

    # this is fragile and silly
    if get_mode(c).eql?(0.0)
      average.delete(:mode)
    end

    r = Hash.new

    [ :title, :url, :date].each do |k|
      r[k] = @meta[k] unless @meta[k].nil?
    end

    r.merge!({
      :total_time      => duration(c),
      :total_segments  => @times.size + 1, # 0 based size
      :fastest_segment => duration(@times.min),
      :slowest_segment => duration(@times.max),
      :average         => average,
    })

    r.each do |k,v|
      puts sprintf('%s%s=>%20s', k, ' ' * (20 - k.size), v)
    end
  end

  # really float to seconds
  def float2time(f)
    c = sprintf('%.2f', f)
    t = c.split('.')
    t.first.to_i * 60 + t.last.to_i
  end

  def get_mean(c)
    # The mean (average) of a data set is found by adding all numbers in the data set and then dividing by the number of values in the set.
    sprintf('%.2f', (c / @times.size.to_f)).to_f
  end

  def get_median(c)
    # The median is the middle value when a data set is ordered from least to greatest
    sorted = @times.sort
    middle_index = sorted.size / 2
    sprintf('%.2f', sorted[middle_index]).to_f
  end

  def get_mode(c)
    # The mode is the number that occurs most often in a data set.
    counts = Hash.new(0)
    @times.each do |t|
      counts[t] += 1
    end

    if counts.values.uniq.eql?(1)
      # this is almost always going to be the case
      return 0.0
    end

    highest_count = counts.values.sort.first

    @times.each do |time|
      if counts[highest_count].eql?(time)
        return time.to_f
      end
    end

    # this should never happen
    0.0
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


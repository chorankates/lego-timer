#!/bin/env ruby
## lego-build-time.rb -

require 'json'
require 'pry'
require 'yaml'

# really float to seconds
def float2time(f)
  c = sprintf('%.2f', f)
  t = c.split('.')
  t.first.to_i * 60 + t.last.to_i
end

def get_average(t)
  c = get_total(t)

  # TODO mean/median/mode ?
  sprintf('%.2f', (c / t.size.to_f)).to_f
end

def get_total(t)
  r = 0
  t.each { |c| r += c }

  r
end

# seconds to H/M/S duration
def duration(s)
  # h/t https://gist.github.com/shunchu/3175001
  Time.at(s).utc.strftime('%Hh %Mm %Ss')
end


# TODO read this in from YAML/JSON
times = [
  ## world map
  # 16x16 panels
  # panel 1
  18.00,
  26.12,
  17.50,
  18.24,
  17.55,
  21.17,
  18.01,
  17.40,
  17.05,
  15.39,
  # panel 2
  15.40,
  14.34,
  16.12,
  15.07,
  16.58,
  16.55,
  17.20,
  16.45,
  15.43,
  15.23,
  18.59,
  18.03,
  16.50,
  16.21,
  13.31,
  18.08,
  14.54,
  15.21,
  15.07,
  14.37,
  # panel 3
  16.21,
  14.37,
  15.34,
  14.24,
  16.15,
  18.20,
  16.51,
  13.20,
  16.12,
]

t = times.collect { |c| float2time(c) }

r = {
  :total_time     => duration(get_total(t)),
  :total_segments => t.size + 1, # 0 based size
  :average_time   => duration(get_average(t)),
  :fastest_time   => duration(t.min),
  :slowest_time   => duration(t.max),
}

r.each do |k,v|
  puts sprintf('%s%s=>%15s', k, ' ' * (15 - k.size), v)
end

binding.pry

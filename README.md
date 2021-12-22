# lego-timer


tool to provide summary and tracking of Lego build times

```
$ ruby lego-build-time.rb builds/world-map.yaml
[10:02.04] [DEBUG] using[builds/world-map.yaml] as input..
[10:02.04] [DEBUG] inspecting[builds/world-map.yaml]
total_time     =>    10h 52m 25s
total_segments =>             40
average_time   =>    00h 16m 43s
fastest_time   =>    00h 13m 20s
slowest_time   =>    00h 26m 12s
title          =>  World Map (A)
url            =>https://www.lego.com/en-us/product/world-map-31203
```

## YAML format

[template.yaml](template.yaml) will be kept up-to-date, but there are 2 pieces to the YAML files:

  - `:meta:` map, which optionally contains `:title:`, `:url:` and `:date:`
  - `:times:` array, which includes times in the format of `minutes.seconds`

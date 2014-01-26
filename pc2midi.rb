#!/usr/bin/env ruby

instruments = {
  0 => "MM",
  10 => "LX",
  11 => "OT",
  14 => "AW"
}

i = ["AW","LX","OT","MM"]

csv = []
bottom = []
t = true
b = false
`midicsv #{ARGV[0]}.mid`.split("\n").each do |line|
  b = true if line.match /2, \d+, End_track/
  csv << line if t
  bottom << line if b
  t = false if line.match /2, 0, Start_track/
end

File.open("#{ARGV[0]}.pc").each_line do |line|
  unless line.match(/^[ #]/)
    line.chomp!
    ticks = 24*4*line[0..2].to_i
    n = 4
    events = []
    i.each_with_index do |inst,j|
      pc = line[n,2]
      if pc and !pc.match /^ +$/
        t = ticks
        t -= 24 unless inst == "AW" # send PC before bar change
        t = 0 if t < 0
        events << "2, #{t}, Program_c, #{instruments.key inst}, #{pc.to_i}"
      end
      n += 3
    end
    csv += events.sort unless events.empty?
  end
end
csv += bottom

`echo "#{csv.join "\n"}" | csvmidi > #{ARGV[0]}.mid`

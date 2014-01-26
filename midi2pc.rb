#!/usr/bin/env ruby

instruments = {
  0 => "MM",
  10 => "LX",
  11 => "OT",
  14 => "AW"
}

i = ["AW","LX","OT","MM"]
seq = {}

`midicsv #{ARGV[0]}.mid`.split("\n").each do |line|
  tokens = line.split ', '
  if tokens.shift.to_i > 1 and tokens[1] =~ /Program_c/
    ticks = tokens.shift.to_i
    bars = (ticks/24/4.0/4).round 
    seq[bars] ||= {}
    seq[bars][instruments[tokens[1].to_i]] = "%02d" % tokens[2]
  end
end

File.open("#{ARGV[0]}.pc","w+") do |f|
  f.puts "    " + i.join(" ")
  (0..(seq.keys.last.to_i).round).each do |n|
    f.print "%03d" % (4*n)
    i.each do |inst|
      seq[n][inst] ? f.print(" #{seq[n][inst]}") : f.print("   ")
    end if seq[n]
    f.puts
  end
end

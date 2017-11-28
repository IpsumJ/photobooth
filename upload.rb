#!/usr/bin/env ruby

$:.unshift(File.expand_path("lib"))

require 'photobooth/config'

if ARGV[0]
  Photobooth::Config.load ARGV[0]
else
  Photobooth::Config.load "config.json"
end


CMD = %w(/usr/bin/curl --user %LOGIN -T %SOURCE %TARGET/%SOURCE).freeze
@login = File.read(Photobooth::Config[:login_file]).chomp

def upload_file file
  cmd = CMD.map do |v|
    v.gsub("%LOGIN", @login)
    .gsub("%SOURCE", file)
    .gsub("%TARGET", Photobooth::Config[:owncloud_url])
  end
  p cmd
  pr = Process.spawn *cmd
  Process.wait pr
  p pr
end

Dir.open(Photobooth::Config[:output_dir]).each do |file|
  if /^\d{4}-\d{2}-\d{2}_\d{4}.jpg$/ =~ file
    p file
  end
end

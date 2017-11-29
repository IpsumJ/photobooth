#!/usr/bin/env ruby

$:.unshift(File.expand_path("lib"))

require 'photobooth/config'

if ARGV[0]
  Photobooth::Config.load ARGV[0]
else
  Photobooth::Config.load "config.json"
end


CMD = %w(/usr/bin/curl --user %LOGIN -f -m %TIMEOUT -T %SOURCE %TARGET/%NAME).freeze
FILE_LIST_NAME = File.join(Photobooth::Config[:output_dir], "uploaded")
@login = File.read(Photobooth::Config[:login_file]).chomp

def upload_file file, name
  cmd = CMD.map do |v|
    v.gsub("%LOGIN", @login)
      .gsub("%SOURCE", file)
      .gsub("%NAME", name)
      .gsub("%TIMEOUT", Photobooth::Config[:max_upload_time].to_s)
      .gsub("%TARGET", Photobooth::Config[:owncloud_url])
  end
  pr = Process.spawn *cmd
  Process.wait pr
  $?.exitstatus == 0
end

def load_file_list
  files = {}
  uploaded = []

  if File.exist? FILE_LIST_NAME
    uploaded = File.read(FILE_LIST_NAME).split("\n").map{|v| v.to_i}
  end

  data_dir = Photobooth::Config[:output_dir]
  Dir.open(data_dir).each do |file|
    if m = /^\d{4}-\d{2}-\d{2}_(\d{4}).jpg$/.match(file)
      index = m[1].to_i
      files[index] = {
        :name => file,
        :file => File.join(data_dir, file),
        :uploaded => uploaded.include?(index)
      }
    end
  end
  files
end


loop do
  files = load_file_list

  files.each do |i, info|
    next if info[:uploaded]
    if upload_file info[:file], info[:name]
      File.write(FILE_LIST_NAME, "#{i}\n", mode: "a")
    end
  end

  sleep 1
end

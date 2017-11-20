#!/usr/bin/env ruby

$:.unshift(File.expand_path("lib"))

require 'photobooth'
require 'photobooth/config'

if ARGV[0]
  Photobooth::Config.load ARGV[0]
else
  Photobooth::Config.load "config.json"
end

Photobooth.new

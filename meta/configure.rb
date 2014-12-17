#!/usr/bin/env ruby

require 'net/http'
require 'dock0'

HOSTNAME = ARGV.first || fail('Please supply a hostname')
CONFIG_FILES = ['config.yaml', "configs/#{HOSTNAME}.yaml"]
CONFIG = CONFIG_FILES.each_with_object({}) do |file, obj|
  next unless File.exist? file
  obj.merge! YAML.load(File.read(file))
end

puts 'Building config tarball'
Dock0.easy_mode :Config, CONFIG_FILES

puts 'Waiting for config flag'
conn = Net::HTTP.new("#{HOSTNAME}#{CONFIG['domain']}", 1002)
conn.open_timeout = 2
begin
  sleep 5
  conn.request('/')
rescue Net::OpenTimeout
  retry
end

puts 'Sending tarball'
ssh_options = [
  'StrictHostKeyChecking=no',
  'UserKnownHostsFile=/dev/null',
  'Port=1001',
  'AddressFamily=inet'
]
system "scp #{ssh_options.map { |x| '-o' + x }.join(' ')} build.tar.gz akerl@grego.a-rwx.org:/tmp/"
system "ssh #{ssh_options.map { |x| '-o' + x }.join(' ')} akerl@grego.a-rwx.org touch /tmp/.keep"

puts 'Done!'
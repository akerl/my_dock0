##
# Configure the root user's environment

require 'fileutils'

# Disable password authentication
shadow_path = "#{@config['paths']['build']}/etc/shadow"
shadow_file = File.readlines shadow_path
shadow_file.first.gsub! 'root::', 'root:x:'
File.open(shadow_path, 'w') { |fh| shadow_file.each { |line| fh << line } }

# Set timezone
FileUtils.ln_s(
  '../usr/share/zoneinfo/US/Eastern',
  "#{@config['paths']['build']}/etc/localtime"
)

# Generate locales
run 'arch-chroot locale-gen'

# Set root user to use zsh
run 'arch-chroot usermod -s /usr/local/bin/zsh'

run 'git clone git://github.com/ingydotnet/....git ' \
  "#{@config['paths']['build']}/root/..."
FileUtils.ln_s(
  '../.dotdotdot.conf',
  "#{@config['paths']['build']}/root/.../conf"
)
%w(update install).each { |x| run "arch-chroot /root/.../... #{x}" }

require 'colorator'
require 'fileutils'
require 'optparse'
require 'time'
require_relative 'media_trim/version' unless defined? MediaTrimVersion::VERSION
require_relative 'trim_class'
require_relative 'trim_help'
require_relative 'trim_main'
require_relative 'trim_run'

if __FILE__ == $PROGRAM_NAME
  media_trim = MediaTrim.new
  media_trim.options
  media_trim.setup ARGV
  media_trim.run
end

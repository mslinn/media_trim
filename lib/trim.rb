require 'colorator'
require 'fileutils'
require 'optparse'
require 'time'
require_relative 'trim/version' unless defined? MediaTrimVersion::VERSION

require_relative 'trim_class'
require_relative 'trim_help'
require_relative 'trim_main'

media_trim = MediaTrim.new
media_trim.options
media_trim.setup
media_trim.run
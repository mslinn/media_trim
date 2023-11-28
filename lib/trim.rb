require 'colorator'
require 'fileutils'
require 'optparse'
require 'time'
require_relative 'trim/version'

# Require all Ruby files in 'lib/', except this file
Dir[File.join(__dir__, '*.rb')].each do |file|
  require file unless file.end_with?('/trim.rb')
end

# @return a new StandardError subclass containing the shorten_backtrace method
def define_error
  Class.new StandardError
end

module_function :define_error

TrimError = define_error

def help(msg=nil)
  puts "Error: #{msg}.\n".red if msg
  puts <<~END_HELP
    #{File.basename $PROGRAM_NAME} - Trim an audio or video file using ffmpeg

    Works with all formats supported by ffmpeg.
    Seeks to the nearest frame positions by re-encoding.
    Reduces file size procduced by OBS Studio by over 80 percent.

    #{File.basename $PROGRAM_NAME} names the output file by adding '.trim' before the file extension.
    By default, does not overwrite pre-existing output files.
    Displays the trimmed file, unless the -q option is specified

    Usage:
      #{File.basename $PROGRAM_NAME} [OPTIONS] dir/file.ext start [[to|for] END]

    OPTIONS are:
      -d Enable debug output
      -f Overwrite output file if present
      -v Verbose output
      -V Do not view the trimmed file when complete.

    start and END have the format [HH:[MM:]]SS[.XXX]
    END defaults to end of audio/video file

    Examples:
      # Crop dir/file.mp4 from 15.0 seconds to the end of the video, save to dir/file.trim.mp4:
      #{File.basename $PROGRAM_NAME} dir/file.mp4 15

      # Crop dir/file.mkv from 3.25 minutes to 9 minutes, 35 seconds, save to dir/file.trim.mkv:
      #{File.basename $PROGRAM_NAME} dir/file.mkv 3:25 9:35

      # Same as the previous example, using optional 'to' syntax:
      #{File.basename $PROGRAM_NAME} dir/file.mkv 3:25 to 9:35

      # Save as the previous example, but specify the duration instead of the end time:
      #{File.basename $PROGRAM_NAME} dir/file.mkv 3:25 for 6:10

    Need a way to figure out the start and stop times to trim a video?
    DJV is an excellent video viewer https://darbyjohnston.github.io/DJV/
    - allows frame-by-frame stepping
    - displays the current time reliabily
    - F/OSS
    - Mac, Windows, Linux
    - High quality
  END_HELP
  exit 1
end

def add_times(str1, str2)
  time1 = Time.parse mk_time str1
  time2 = Time.parse mk_time str2
  m = time2.strftime("%M").to_i
  h = time2.strftime("%H").to_i
  s = time2.strftime("%S").to_i
  millis = time2.strftime("%L").to_f / 1000.0
  (time1 + (h * 60 * 60) + (m * 60) + s + millis).strftime("%H:%M:%S")
end

def time_format(elapsed_seconds)
  elapsed_time = elapsed_seconds.to_i
  hours = (elapsed_time / (60 * 60)).to_i
  minutes = ((elapsed_time - (hours * 60)) / 60).to_i
  seconds = elapsed_time - (hours * 60 * 60) - (minutes * 60)

  result = "#{minutes.to_s.rjust 2, '0'}:#{seconds.to_s.delete_suffix('.0').rjust 2, '0'}"
  result = "#{hours}:#{result}}" unless hours.zero?
  result
end

# @return time difference HH:MM:SS, ignoring millis
def duration(str1, str2)
  time1 = Time.parse mk_time str1
  time2 = Time.parse mk_time str2

  time_format(time2 - time1)
end

# Expand an environment variable reference
def expand_env(str, die_if_undefined: false)
  str&.gsub(/\$([a-zA-Z_][a-zA-Z0-9_]*)|\${\g<1>}|%\g<1>%/) do
    envar = Regexp.last_match(1)
    raise TrimError, "Trim error: #{envar} is undefined".red, [] \
      if !ENV.key?(envar) && die_if_undefined # Suppress stack trace

    ENV.fetch(envar, nil)
  end
end

def mk_time(str)
  case str.count ':'
  when 0 then "0:0:#{str}"
  when 1 then "0:#{str}"
  when 2 then str
  else raise StandardError, "Error: #{str} is not a valid time"
  end
end

def to_seconds(str)
  array = str.split(':').map(&:to_i).reverse
  case array.length
  when 1 then str.to_i
  when 2 then array[0] + (array[1] * 60)
  when 3 then array[0] + (array[1] * 60) + (array[2] * 60 * 60)
  else raise StandardError, "Error: #{str} is not a valid time"
  end
end

overwrite = '-n'
quiet = ['-hide_banner', '-loglevel', 'error', '-nostats']
view = true
OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

  opts.on('-f', '--[no-]overwrite', 'Overwrite any previous output') do |f|
    overwrite = f ? '-y' : '-n'
  end
  opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
    quiet = [] if v
  end
  opts.on('-h', '', 'Run verbosely') do |_|
    help
  end
  opts.on('-V', '--[no-]view', 'View ffmpeg output') do |v|
    view = false if v
  end
end.parse!

help 'Please specify the name of the video file to trim' unless ARGV[0]
fname = expand_env ARGV[0]
unless File.exist? fname
  puts "Error: '#{File.realpath fname}' does not exist.".red
  exit 1
end
original_filename = File.basename fname, '.*'
ext = File.extname fname
copy_filename = "#{File.dirname fname}/trim.#{original_filename}#{ext}"

help 'Please specify the time to start trimming the video file from' unless ARGV[1]
start = ARGV[1]

interval = ['-ss', start]
msg_end = ''
to_index = 2
if ARGV[to_index]
  to_index += 1 if ARGV[to_index] == 'to'
  if ARGV[to_index] == 'for'
    to = time_format ARGV[to_index + 1]
    help 'No duration was specified' unless to
    interval += ['-t', to]
    time_end = add_times start, to
    msg_end = " for a duration of #{to} (until #{time_end})"
  else
    to = time_format(to_seconds(ARGV[to_index]))
    elapsed_time = duration start, to
    interval += ['-to', to]
    msg_end = " to #{to} (duration #{elapsed_time})"
  end
  if start >= to
    puts "Error: start time (#{start}) must be before end time (#{to})"
    exit 2
  end
end

puts "Trimming '#{fname}' from #{start}#{msg_end}".cyan
command = ['ffmpeg',
           *quiet,
           '-hwaccel', 'auto',
           overwrite,
           '-i', fname,
           '-acodec', 'aac',
           *interval,
           copy_filename
          ]
# puts command.join(' ').yellow
start_clock = Process.clock_gettime(Process::CLOCK_MONOTONIC)
status = system(*command)
end_clock = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = end_clock - start_clock
puts "Trim took #{time_format elapsed.to_i}".cyan
$stdout.flush
exit 1 unless status

# View trimmed file unless -q option was specified
if view
  # Open in Windows if running in WSL
  if File.exist? '/mnt/c/Program Files/DJV2/bin/djv.com'
    realpath = File.realpath copy_filename
    windows_path = `wslpath -m '#{realpath}'`.chomp
    spawn 'cmd.exe', '/c',
          "C:\\Program Files\\DJV2\\bin\\djv.com",
          '-full_screen',
          '-full_screen_monitor', '2',
          windows_path
  elsif `which cmd.exe`
    exec 'cmd.exe', '/C', 'start', copy_filename, "--extraintf='luaintf{intf=\"looper_custom_time\"}'"
  elsif `which xdg-open`
    # Open any file with its default Linux application with xdg-open.
    # Define default apps in ~/.local/share/applications/defaults.list,
    # which is read on every invocation.
    # See https://askubuntu.com/questions/809981/set-the-default-video-player-from-the-command-line
    exec 'xdg-open', copy_filename
  end
end

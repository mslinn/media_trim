class MediaTrim
  # @return a new StandardError subclass containing the shorten_backtrace method
  TrimError = define_error

  attr_accessor :copy_filename, :fname, :interval, :msg_end, :overwrite, :quiet, :start, :view

  def set_defaults
    @overwrite = '-n'
    @quiet = ['-hide_banner', '-loglevel', 'error', '-nostats']
    @view = true
  end

  def options
    set_defaults
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

      opts.on('-f', '--[no-]@overwrite', 'Overwrite any previous output') do |f|
        @overwrite = f ? '-y' : '-n'
      end
      opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
        @quiet = [] if v
      end
      opts.on('-h', '', 'Run verbosely') do |_|
        help
      end
      opts.on('-V', '--[no-]@view', 'View ffmpeg output') do |v|
        @view = false if v
      end
    end.parse!
  end

  # @param argv [array] Copy of ARGV
  def setup(argv)
    MediaTrim.help 'Please specify the name of the video file to trim' unless argv[0]
    @fname = MediaTrim.expand_env argv[0]
    unless File.exist? @fname
      puts "Error: '#{File.realpath @fname}' does not exist.".red
      exit 1
    end
    original_filename = File.basename @fname, '.*'
    ext = File.extname @fname
    @copy_filename = "#{File.dirname @fname}/trim.#{original_filename}#{ext}"

    MediaTrim.help 'Please specify the time to @start trimming the video file from' unless argv[1]
    @start = MediaTrim.time_format argv[1]

    @interval = ['-ss', @start]
    @msg_end = ''
    to_index = 2
    return unless argv[to_index]

    to_index += 1 if argv[to_index] == 'to'
    if argv[to_index] == 'for'
      to = MediaTrim.time_format argv[to_index + 1]
      MediaTrim.help 'No duration was specified' unless to
      @interval += ['-t', to]
      time_end = MediaTrim.add_times @start, to
      @msg_end = " for a duration of #{to} (until #{time_end})"
    else
      to = MediaTrim.time_format(MediaTrim.to_seconds(argv[to_index]))
      elapsed_time = MediaTrim.duration @start, to
      @interval += ['-to', to]
      @msg_end = " to #{to} (MediaTrim.duration #{elapsed_time})"
    end
    return unless @start >= to

    puts "Error: @start time (#{@start}) must be before end time (#{to})"
    exit 2
  end

  def run
    puts "Trimming '#{@fname}' from #{@start}#{@msg_end}".cyan
    command = ['ffmpeg',
               *@quiet,
               '-hwaccel', 'auto',
               @overwrite,
               '-i', @fname,
               '-acodec', 'aac',
               *@interval,
               @copy_filename]
    # puts command.join(' ').yellow
    start_clock = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    status = system(*command)
    end_clock = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed = end_clock - start_clock
    puts "Trim took #{MediaTrim.time_format elapsed.to_i}".cyan
    $stdout.flush
    exit 1 unless status

    # View trimmed file unless -q option was specified
    return unless @view

    # Open in Windows if running in WSL
    if File.exist? '/mnt/c/Program Files/DJV2/bin/djv.com'
      realpath = File.realpath @copy_filename
      windows_path = `wslpath -m '#{realpath}'`.chomp
      spawn 'cmd.exe', '/c',
            'C:\\Program Files\\DJV2\\bin\\djv.com',
            '-full_screen',
            '-full_screen_monitor', '2',
            windows_path
    elsif `which cmd.exe`
      exec 'cmd.exe', '/C', '@start', @copy_filename, "--extraintf='luaintf{intf=\"looper_custom_time\"}'"
    elsif `which xdg-open`
      # Open any file with its default Linux application with xdg-open.
      # Define default apps in ~/.local/share/applications/defaults.list,
      # which is read on every invocation.
      # See https://askubuntu.com/questions/809981/set-the-default-video-player-from-the-command-line
      exec 'xdg-open', @copy_filename
    end
  end
end

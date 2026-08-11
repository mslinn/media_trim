class MediaTrim
  def run
    raise TrimError, 'Error: No filename was specified'.red unless @fname
    raise TrimError, 'Error: No trimmed filename was specified'.red unless @copy_filename
    raise TrimError, 'Error: No starting timestamp was specified'.red unless @start
    raise TrimError, 'Error: Starting timestamp must be a string'.red unless @start.instance_of? String

    puts "Trimming '#{@fname}' from #{@start}#{@msg_end}".cyan

    # Run preflight checks which may print warnings or exit on fatal errors.
    preflight_warnings = preflight_check @fname

    # Build ffmpeg command. Respect explicit no-hwaccel option.
    base_args = ['ffmpeg', *@quiet, @overwrite, '-i', @fname, '-acodec', 'aac', *@interval, @copy_filename]

    if @no_hwaccel
      command = base_args
    else
      command = ['ffmpeg', *@quiet, '-hwaccel', 'auto', @overwrite, '-i', @fname, '-acodec', 'aac', *@interval, @copy_filename]
    end

    # Execute ffmpeg (timed). If hwaccel was used and failed, retry once without hwaccel.
    start_clock = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    status = system(*command)
    end_clock = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed = end_clock - start_clock
    puts "Trim took #{MediaTrim.time_format elapsed.to_i}".cyan
    $stdout.flush

    unless status
      # If we attempted hwaccel and it failed, retry in software mode once.
      if !@no_hwaccel && command.include?('-hwaccel')
        puts "Warning: hardware acceleration failed. Retrying with software decoding, which may be slower but will produce the correct result.".yellow
        soft_command = base_args
        start_clock = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        status = system(*soft_command)
        end_clock = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        elapsed = end_clock - start_clock
        puts "Retry (software) took #{MediaTrim.time_format elapsed.to_i}".cyan
        $stdout.flush
      end
      exit 1 unless status
    end

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

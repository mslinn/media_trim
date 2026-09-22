class MediaTrim
  def open_file(target)
    if File.exist? target
      windows_path = `wslpath -w "#{File.expand_path target}"`.strip
      system 'cmd.exe', '/c', 'start', '""', windows_path
    else
      system 'cmd.exe', '/c', 'start', '""', target
    end
  end

  def djv_executable
    paths = Dir.glob('/mnt/c/Program Files/DJV */bin/djv.com')
    return if paths.empty?

    path = paths.max_by do |path|
      match = File.basename(File.dirname(File.dirname(path))).match(/\ADJV\s+([\d.]+)\z/)
      Gem::Version.new(match[1])
    end

    `wslpath -w "#{path}"`.strip
  end

  def trim
    raise TrimError, 'Error: No filename was specified'.red unless @fname
    raise TrimError, 'Error: No trimmed filename was specified'.red unless @copy_filename
    raise TrimError, 'Error: No starting timestamp was specified'.red unless @start
    raise TrimError, 'Error: Starting timestamp must be a string'.red unless @start.instance_of? String

    puts "Trimming '#{@fname}' from #{@start}#{@msg_end}".cyan

    # Run preflight checks which may print warnings or exit on fatal errors.
    preflight_check @fname

    # Build ffmpeg command. Respect explicit no-hwaccel option.
    base_args = ['ffmpeg', *@quiet, @overwrite, '-i', @fname, '-acodec', 'aac', *@interval, @copy_filename]

    command = if @no_hwaccel
                base_args
              else
                ['ffmpeg', *@quiet, '-hwaccel', 'auto', @overwrite, '-i', @fname, '-acodec', 'aac', *@interval, @copy_filename]
              end

    # Execute ffmpeg (timed). If hwaccel was used and failed, retry once without hwaccel.
    start_clock = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    status = run command
    end_clock = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed = end_clock - start_clock
    puts "Trim took #{MediaTrim.time_format elapsed.to_i}".cyan
    $stdout.flush

    unless status
      # If we attempted hwaccel and it failed, retry in software mode once.
      if !@no_hwaccel && command.include?('-hwaccel')
        puts 'Warning: hardware acceleration failed. Retrying with software decoding, which may be slower but will produce the correct result.'.yellow
        soft_command = base_args
        start_clock = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        status = run soft_command
        end_clock = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        elapsed = end_clock - start_clock
        puts "Retry (software) took #{MediaTrim.time_format elapsed.to_i}".cyan
        $stdout.flush
      end
      exit 1 unless status
    end

    # View trimmed file unless -q option was specified
    return unless @view

    djv = djv_executable
    if djv
      realpath = File.realpath @copy_filename
      windows_path = `wslpath -m '#{realpath}'`.chomp

      pid = spawn 'cmd.exe', '/c',
                  djv,
                  '-full_screen',
                  '-full_screen_monitor', '2',
                  windows_path,
                  in:  File::NULL,
                  out: File::NULL,
                  err: File::NULL

      Process.detach pid
    elsif `which cmd.exe`
      open_file @copy_filename
    elsif `which xdg-open`
      # Open any file with its default Linux application with xdg-open.
      # Define default apps in ~/.local/share/applications/defaults.list,
      # which is read on every invocation.
      # See https://askubuntu.com/questions/809981/set-the-default-video-player-from-the-command-line
      exec 'xdg-open', @copy_filename
    end
  end
end

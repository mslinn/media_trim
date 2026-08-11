require 'open3'
require 'shellwords'

class MediaTrim
  # Run a set of preflight checks and either exit on fatal errors or
  # return an array of warning messages. The method uses clear, full-sentence
  # messages so the user understands what is missing or degraded.
  def preflight_check(input)
    warnings = []

    # Check that ffmpeg is installed
    unless system('which ffmpeg > /dev/null 2>&1')
      puts "Fatal: ffmpeg is not installed. Please install ffmpeg and try again.".red
      exit 1
    end

    # Probe hardware acceleration initialization in a lightweight way. If
    # this fails with hardware-specific errors we will warn and allow a
    # software retry later. If probing fails for decoding reasons, that is fatal.
    probe_cmd = ['ffmpeg', '-v', 'error', '-hwaccel', 'auto', '-i', input, '-t', '1', '-f', 'null', '-']
    _, stderr, status = Open3.capture3(*probe_cmd)

    if !status.success?
      hwaccel_errors = [/CUDA_ERROR_NO_DEVICE/, /Failed to initialise VAAPI/, /Cannot open the X11 display/, /Device does not support VK_KHR_video_decode_queue/, /hwaccel/]
      if hwaccel_errors.any? { |rx| stderr =~ rx }
        warnings << "Hardware acceleration could not be initialized: #{stderr.lines.first(2).join(' ').strip}. The command will be retried using software decoding, which is slower but produces the same result." 
      else
        # If hw probe fails for other reasons, check software decoding capability.
        sw_cmd = ['ffmpeg', '-v', 'error', '-i', input, '-t', '1', '-f', 'null', '-']
        _, sw_stderr, sw_status = Open3.capture3(*sw_cmd)
        unless sw_status.success?
          puts "Fatal: ffmpeg cannot decode the input file. #{sw_stderr.lines.first(2).join(' ').strip}".red
          exit 1
        end
      end
    end

    # Check available disk space in destination directory.
    begin
      dest_dir = Shellwords.escape(File.dirname(input))
      avail = `df --output=avail -B1 #{dest_dir} 2>/dev/null`.lines.last.to_i
    rescue StandardError
      avail = 0
    end
    if avail == 0 || avail < 100_000_000
      puts "Fatal: There is less than 100 MB of free space available in the destination directory. Please free space and try again.".red
      exit 1
    end

    # If we reach here, return any collected warnings for user information.
    warnings.each { |w| puts "Warning: #{w}".yellow }
    warnings
  end
end

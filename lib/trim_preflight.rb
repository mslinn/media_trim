require 'open3'
require 'shellwords'

class MediaTrim
  def run(command)
    _, stderr, status = Open3.capture3(*command)
    return true if status.success?

    puts "Command failed with status #{status.exitstatus}:\n  #{command.shelljoin}".red
    puts stderr.lines.first(2).join(' ').strip.red
    false
  end

  def preflight_check(input)
    # Check that ffmpeg is installed
    unless system('which ffmpeg > /dev/null 2>&1')
      puts 'Fatal: ffmpeg is not installed. Please install ffmpeg and try again.'.red
      exit 1
    end

    # Verify that the input can be decoded in software.
    sw_cmd = ['ffmpeg', '-v', 'error', '-i', input, '-t', '1', '-f', 'null', '-']
    exit 1 unless run sw_cmd

    # Check available disk space in destination directory.
    begin
      dest_dir = Shellwords.escape(File.dirname(input))
      avail = `df --output=avail -B1 #{dest_dir} 2>/dev/null`.lines.last.to_i
    rescue StandardError
      avail = 0
    end

    return unless avail.zero? || avail < 100_000_000

    puts 'Fatal: There is less than 100 MB of free space available in the destination directory. Please free space and try again.'.red
    exit 1
  end
end

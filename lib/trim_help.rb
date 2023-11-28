class MediaTrim
  def self.help(msg = nil)
    puts "Error: #{msg}.\n".red if msg
    puts <<~END_HELP
      media_trim - Trim an audio or video file using ffmpeg

      - Works with all formats supported by ffmpeg, including mp3, mp4, mkv, and many more.
      - Seeks to the nearest frame positions by re-encoding the media.
      - Reduces file size produced by OBS Studio by over 80 percent.
      - Can be used as a Ruby gem.
      - Installs the 'trim' command.

      When run as a command, output files are named by adding a 'trim.' prefix to the media file name, e.g. 'dir/trim.file.ext'.
      By default, the trim command does not overwrite pre-existing output files.
      When trimming is complete, the trim command displays the trimmed file, unless the -q option is specified

      Command-line Usage:
        trim [OPTIONS] dir/file.ext start [[to|for] end]

      - The start and end timecodes have the format [HH:[MM:]]SS[.XXX]
        Note that decimal seconds may be specified, but frames may not;
        this is consistent with how ffmpeg parses timecodes.
      - end defaults to the end of the audio/video file

      OPTIONS are:
        -d Enable debug output
        -f Overwrite output file if present
        -h Display help information.
        -v Verbose output
        -V Do not view the trimmed file when complete.

      Examples:
        # Crop dir/file.mp4 from 15.0 seconds to the end of the video, save to demo/trim.demo.mp4:
        trim demo/demo.mp4 15

        # Crop dir/file.mkv from 3 minutes, 25 seconds to 9 minutes, 35 seconds, save to demo/trim.demo.mp4:
        trim demo/demo.mp4 3:25 9:35

        # Same as the previous example, using optional 'to' syntax:
        trim demo/demo.mp4 3:25 to 9:35

        # Save as the previous example, but specify the duration instead of the end time by using the for keyword:
        trim demo/demo.mp4 3:25 for 6:10

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
end

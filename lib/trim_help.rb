class MediaTrim
  def self.help(msg = nil)
    puts "Error: #{msg}.\n".red if msg
    puts <<~END_HELP
      #{File.basename $PROGRAM_NAME} - Trim an audio or video file using ffmpeg

      Works with all formats supported by ffmpeg.
      Seeks to the nearest frame positions by re-encoding.
      Reduces file size produced by OBS Studio by over 80 percent.

      #{File.basename $PROGRAM_NAME} names the output file by adding a 'trim.' prefix to the media file name.
      By default, trim does not overwrite pre-existing output files.
      Displays the trimmed file, unless the -q option is specified

      Usage:
        #{File.basename $PROGRAM_NAME} [OPTIONS] dir/file.ext start [[to|for] end]

      OPTIONS are:
        -d Enable debug output
        -f Overwrite output file if present
        -v Verbose output
        -V Do not view the trimmed file when complete.

      start and end have the format [HH:[MM:]]SS[.XXX]
      end defaults to the end of audio/video file

      Examples:
        # Crop dir/file.mp4 from 15.0 seconds to the end of the video, save to dir/trim.file.mp4:
        #{File.basename $PROGRAM_NAME} dir/file.mp4 15

        # Crop dir/file.mkv from 3 minutes, 25 seconds to 9 minutes, 35 seconds, save to dir/trim.file.mkv:
        #{File.basename $PROGRAM_NAME} dir/file.mkv 3:25 9:35

        # Same as the previous example, using optional 'to' syntax:
        #{File.basename $PROGRAM_NAME} dir/file.mkv 3:25 to 9:35

        # Save as the previous example, but specify the duration instead of the end time by using the for keyword:
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
end

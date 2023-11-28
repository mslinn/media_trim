require_relative 'lib/media_trim/version' unless defined? MediaTrimVersion::VERSION

Gem::Specification.new do |spec|
  host = 'https://github.com/mslinn/media_trim'

  spec.authors               = ['Mike Slinn']
  spec.bindir                = 'binstub'
  spec.executables           = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.description           = <<~END_DESC
    Trim an audio or video file using ffmpeg

    - Works with all formats supported by ffmpeg, including mp3, mp4, mkv, and many more.
    - Seeks to the nearest frame positions by re-encoding the media.
    - Reduces file size procduced by OBS Studio by over 80 percent.
    - Can be used as a Ruby gem.
    - Installs the 'trim' command.

    When run as a command, output files are named by adding a 'trim.' prefix to the media file name, e.g. 'dir/trim.file.ext'.
    By default, the trim command does not overwrite pre-existing output files.
    When trimming is complete, the trim command displays the trimmed file, unless the -q option is specified

    Command-line Usage:
      trim [OPTIONS] dir/file.ext start [[to|for] end]

    - The start and end timecodes have the format [HH:[MM:]]SS[.XXX]
      Note that decimal seconds may be specified, bug frames may not;
      this is consistent with how ffmpeg parses timecodes.
    - end defaults to end of the audio/video file

    OPTIONS are:
      -d Enable debug output.
      -f Overwrite output file if present.
      -h Display help information.
      -v Verbose output.
      -V Do not @view the trimmed file when complete.

    Examples:
      # Crop dir/file.mp4 from 15.0 seconds to the end of the video, save to demo/trim.demo.mp4:
      trim demo/demo.mp4 15

      # Crop dir/file.mkv from 3 minutes, 25 seconds to 9 minutes, 35 seconds, save to demo/trim.demo.mp4:
      trim demo/demo.mp4 3:25 9:35

      # Same as the previous example, using optional 'to' syntax:
      trim demo/demo.mp4 3:25 to 9:35

      # Save as the previous example, but specify the duration instead of the end time by using the for keyword:
      trim demo/demo.mp4 3:25 for 6:10
  END_DESC
  spec.email                 = ['mslinn@mslinn.com']
  spec.files                 = Dir['.rubocop.yml', 'LICENSE.*', 'Rakefile', '{lib,spec}/**/*', '*.gemspec', '*.md']
  spec.homepage              = 'https://www.mslinn.com/av_studio/425-trimming-media.html'
  spec.license               = 'MIT'
  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri'   => "#{host}/issues",
    'changelog_uri'     => "#{host}/CHANGELOG.md",
    'homepage_uri'      => spec.homepage,
    'source_code_uri'   => host,
  }
  spec.name                 = 'media_trim'
  spec.post_install_message = <<~END_MESSAGE

    Thanks for installing #{spec.name} v#{MediaTrimVersion::VERSION}!

  END_MESSAGE
  spec.require_paths         = ['lib']
  spec.required_ruby_version = '>= 2.5.0'
  spec.summary               = 'Trim an audio or video file using ffmpeg'
  spec.version               = MediaTrimVersion::VERSION

  spec.add_dependency 'colorator'
end

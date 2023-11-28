require_relative 'lib/trim/version' unless defined? MediaTrimVersion::VERSION

Gem::Specification.new do |spec|
  host = 'https://github.com/mslinn/trim'

  spec.authors               = ['Mike Slinn']
  spec.bindir                = 'binstub'
  spec.executables           = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.description           = <<~END_DESC
    Trim an audio or video file using ffmpeg

    Works with all formats supported by ffmpeg.
    Seeks to the nearest frame positions by re-encoding.
    Reduces file size procduced by OBS Studio by over 80 percent.

    #{spec.name} names the output file by adding '.trim' before the file extension.
    By default, does not @overwrite pre-existing output files.
    Displays the trimmed file, unless the -q option is specified

    Usage:
      #{spec.name} [OPTIONS] dir/file.ext start [[to|for] END]

    OPTIONS are:
      -d Enable debug output
      -f Overwrite output file if present
      -v Verbose output
      -V Do not @view the trimmed file when complete.

    start and END have the format [HH:[MM:]]SS[.XXX]
    END defaults to end of audio/video file

    Examples:
      # Crop dir/file.mp4 from 15.0 seconds to the end of the video, save to dir/file.trim.mp4:
      #{spec.name} dir/file.mp4 15

      # Crop dir/file.mkv from 3.25 minutes to 9 minutes, 35 seconds, save to dir/file.trim.mkv:
      #{spec.name} dir/file.mkv 3:25 9:35

      # Same as the previous example, using optional 'to' syntax:
      #{spec.name} dir/file.mkv 3:25 to 9:35

      # Save as the previous example, but specify the duration instead of the end time:
      #{spec.name} dir/file.mkv 3:25 for 6:10
  END_DESC
  spec.email                 = ['mslinn@mslinn.com']
  spec.files                 = Dir['.rubocop.yml', 'LICENSE.*', 'Rakefile', '{lib,spec}/**/*', '*.gemspec', '*.md']
  spec.homepage              = 'https://github.com/mslinn/trim'
  spec.license               = 'MIT'
  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri'   => "#{host}/issues",
    'changelog_uri'     => "#{host}/CHANGELOG.md",
    'homepage_uri'      => spec.homepage,
    'source_code_uri'   => host,
  }
  spec.name                 = 'trim'
  spec.post_install_message = <<~END_MESSAGE

    Thanks for installing #{spec.name}!

  END_MESSAGE
  spec.require_paths         = ['lib']
  spec.required_ruby_version = '>= 2.5.0'
  spec.summary               = 'MediaTrim an audio or video file using ffmpeg'
  spec.version               = MediaTrimVersion::VERSION

  spec.add_dependency 'colorator'
end

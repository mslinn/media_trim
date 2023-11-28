# `media_trim` [![Gem Version](https://badge.fury.io/rb/media_trim.svg)](https://badge.fury.io/rb/media_trim)

Trims an audio or video file using `ffmpeg`.

* Works with all formats supported by ffmpeg.
* Seeks to the nearest frame positions by re-encoding the media.
* Reduces file size produced by OBS Studio by over 80 percent.
* Can be used as a Ruby gem.
* Installs the `trim` command.


## Installation

### Standalone

Type:

```shell
$ gem install media_trim
```

### As a Dependency of a Ruby Program

Add this line to your application&rsquo;s `Gemfile`:

```ruby
gem 'media_trim'
```

Then execute:

```shell
$ bundle
```

### As a Dependency of a Ruby Gem

Add the following to your application&rsquo;s `.gemspec`:

```ruby
spec.add_dependency 'media_trim'
```

Then execute:

```shell
$ bundle
```

## Usage

### Command-line Usage

```shell
trim [OPTIONS] dir/file.ext start [[to|for] end]
```

* `start` and `end` timecodes have the format [HH:[MM:]]SS[.XXX].
  Note that decimal seconds may be specified, but frames may not;
  this is consistent with how ffmpeg parses timecodes.
* `end` defaults to the end of audio/video file

When run as a command, output files are named by adding a `trim.` prefix to the media file name,
e.g. `dir/trim.file.ext`.
By default, the `trim` command does not overwrite pre-existing output files.
When trimming is complete, the `trim` command displays the trimmed file,
unless the `-q` option is specified.

`OPTIONS` are:

* `-d` Enable debug output.
* `-f` Overwrite output file if present.
* `-v` Verbose output.
* `-V` Do not view the trimmed file when complete.


#### Examples

Crop `dir/file.mp4` from 15.0 seconds to the end of the video, save to `dir/trim.file.mp4`:

```shell
$ trim dir/file.mp4 15
```

Crop dir/file.mkv from 3 minutes, 25 seconds to 9 minutes, 35 seconds, save to `dir/trim.file.mkv`:

```shell
$ trim dir/file.mkv 3:25 9:35
```

Same as the previous example, using optional `to` syntax:

```shell
$ trim dir/file.mkv 3:25 to 9:35
```

Save as the previous example, but specify the duration instead of the end time by using the `for` keyword:

```shell
$ trim dir/file.mkv 3:25 for 6:10
```


## Figuring Out Start and Stop Times

Need a way to figure out the start and stop times to trim a video?
[DJV](https://darbyjohnston.github.io/DJV/) is an excellent video viewer.

* Allows frame-by-frame stepping
* Displays the current time reliabily
* F/OSS
* Mac, Windows, Linux
* High quality


## Development

After checking out this git repository, install dependencies by typing:

```shell
$ bin/setup
```

You should do the above before running Visual Studio Code.


### Run the Tests

```shell
$ bundle exec rake test
```


### Interactive Session

The following will allow you to experiment:

```shell
$ bin/console
```


### Local Installation

To install this gem onto your local machine, type:

```shell
$ bundle exec rake install
```


### To Release A New Version

To create a git tag for the new version, push git commits and tags,
and push the new version of the gem to https://rubygems.org, type:

```shell
$ bundle exec rake release
```


## Contributing

Bug reports and pull requests are welcome at https://github.com/mslinn/trim.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

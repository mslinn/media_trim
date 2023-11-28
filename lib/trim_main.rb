TrimError = Class.new StandardError # Define a new StandardError subclass

class MediaTrim
  attr_accessor :copy_filename, :fname, :interval, :msg_end, :overwrite, :quiet, :start, :view

  # @param to [String] end timecode; duration not supported
  def initialize(filename = nil, trimmed_filename = nil, start = '0', to = nil, **options)
    @fname = MediaTrim.expand_env(filename) if filename
    @copy_filename = MediaTrim.expand_env(trimmed_filename) if trimmed_filename
    @start = MediaTrim.time_format start
    @interval = ['-ss', MediaTrim.time_format(@start)]

    @overwrite = options[:overwrite] ? '-y' : '-n'
    @quiet     = options[:quiet].nil? || options[:quiet] ? ['-hide_banner', '-loglevel', 'error', '-nostats'] : []
    @view      = options[:view].nil? ? true : options[:view]

    prepare(@start, to, mode: :timecode) if to
  end

  def options
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

      opts.on('-f', '--[no-]@overwrite', 'Overwrite any previous output') do |f|
        @overwrite = f ? '-y' : '-n'
      end
      opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
        @quiet = [] if v
      end
      opts.on('-h', '', 'Display help') do |_|
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
    index = 2
    return unless argv.length > index

    if argv[index] == 'for' # duration
      index += 1
      MediaTrim.help 'No duration was specified' unless argv.length > index
      to = prepare @start, argv[index], mode: :duration
    else # end timecode
      index += 1 if argv[index] == 'to'
      MediaTrim.help 'No end time was specified' unless argv.length > index
      to = prepare @start, argv[index], mode: :timecode
    end
    return unless @start >= to

    raise TrimError, "Error: @start time (#{@start}) must be before end time (#{to})" if @start >= to
  end

  def prepare(from, duration_or_timecode, mode: :duration)
    if mode == :duration
      timecode = MediaTrim.time_format duration_or_timecode
      time_end = MediaTrim.add_times from, timecode
      @interval += ['-t', time_end]
      @msg_end = " for a duration of #{timecode} (until #{time_end})"
    else # end timecode was specified
      time_end = MediaTrim.time_format(MediaTrim.to_seconds(duration_or_timecode))
      elapsed_time = MediaTrim.duration from, time_end
      @interval += ['-to', time_end]
      @msg_end = " to #{time_end} (duration #{elapsed_time})"
    end
    time_end
  end
end

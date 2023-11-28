class MediaTrim
  def self.add_times(str1, str2)
    time1 = Time.parse mk_time str1
    time2 = Time.parse mk_time str2
    h = time2.strftime('%H').to_i
    m = time2.strftime('%M').to_i
    s = time2.strftime('%S').to_i
    millis = time2.strftime('%L').to_f / 1000.0
    sum = (time1 + (h * 60 * 60) + (m * 60) + s + millis)
    return sum.strftime('%H:%M:%S') if h.positive?

    sum.strftime('%M:%S')
  end

  def self.time_format(elapsed_seconds)
    elapsed_time = elapsed_seconds.to_i
    hours = (elapsed_time / (60 * 60)).to_i
    minutes = ((elapsed_time - (hours * 60)) / 60).to_i
    seconds = elapsed_time - (hours * 60 * 60) - (minutes * 60)

    result = "#{minutes.to_s.rjust 2, '0'}:#{seconds.to_s.delete_suffix('.0').rjust 2, '0'}"
    result = "#{hours}:#{result}}" unless hours.zero?
    result
  end

  # @return time difference HH:MM:SS, ignoring millis
  def self.duration(str1, str2)
    time1 = Time.parse mk_time str1
    time2 = Time.parse mk_time str2

    MediaTrim.time_format(time2 - time1)
  end

  # Expand an environment variable reference
  def self.expand_env(str, die_if_undefined: false)
    str&.gsub(/\$([a-zA-Z_][a-zA-Z0-9_]*)|\${\g<1>}|%\g<1>%/) do
      envar = Regexp.last_match(1)
      raise TrimError, "MediaTrim error: #{envar} is undefined".red, [] \
        if !ENV.key?(envar) && die_if_undefined # Suppress stack trace

      ENV.fetch(envar, nil)
    end
  end

  def self.mk_time(str)
    case str.count ':'
    when 0 then "0:0:#{str}"
    when 1 then "0:#{str}"
    when 2 then str
    else raise TrimError, "Error: #{str} is not a valid time"
    end
  end

  def self.to_seconds(str)
    array = str.split(':').map(&:to_i).reverse
    case array.length
    when 1 then str.to_i
    when 2 then array[0] + (array[1] * 60)
    when 3 then array[0] + (array[1] * 60) + (array[2] * 60 * 60)
    else raise TrimError, "Error: #{str} is not a valid time"
    end
  end
end

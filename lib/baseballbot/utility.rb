# frozen_string_literal: true

class Baseballbot
  module Utility
    SUBTRACT_THREE_HOURS = -> { it - 10_800 }

    def self.parse_time_zone(name)
      TZInfo::Timezone.get name
    rescue TZInfo::InvalidTimezoneIdentifier
      TZInfo::Timezone.get 'America/Los_Angeles'
    end

    def self.parse_time(utc, in_time_zone:)
      utc = Time.parse(utc).utc unless utc.is_a? Time

      time_zone = in_time_zone.is_a?(TZInfo::DataTimezone) ? in_time_zone : parse_time_zone(in_time_zone)

      period = time_zone.period_for_utc(utc)
      with_offset = utc + period.utc_total_offset

      Time.parse "#{with_offset.strftime('%FT%T')} #{period.zone_identifier}"
    end

    def self.adjust_time_proc(post_at)
      case post_at
      when /\A-\d{1,2}\z/
        -> { it + (post_at.to_i * 3600) }
      when /(1[012]|0?\d):(\d\d)/i
        -> { Time.new(it.year, it.month, it.day, Regexp.last_match[1].to_i, Regexp.last_match[2].to_i, 0) }
      else
        # Default to 3 hours before game time
        SUBTRACT_THREE_HOURS
      end
    end
  end
end

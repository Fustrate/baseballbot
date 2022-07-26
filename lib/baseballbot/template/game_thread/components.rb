# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Components
        def header = "#{away_team.name} (#{away_record}) @ #{home_team.name} (#{home_record})"

        def first_pitch = "**First Pitch**: #{start_time_local.strftime('%-I:%M %p')} at #{venue_name}"
      end
    end
  end
end

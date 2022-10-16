# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      # TODO: Move more code here - the four table generators, maybe?
      module BoxScore
        def box_score = [away_batters_table, away_pitchers_table, home_batters_table, home_pitchers_table].join("\n\n")
      end
    end
  end
end

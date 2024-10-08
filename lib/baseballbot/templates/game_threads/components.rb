# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Components
        def header
          <<~MARKDOWN.strip
            ### #{away_team.name} (#{away_record}) @ #{home_team.name} (#{home_record})

            #{first_pitch}
          MARKDOWN
        end

        def first_pitch = "**First Pitch**: #{start_time_local.strftime('%-I:%M %p')} at #{venue_name}"

        def final_score
          "**Final Score**: #{away_team.name} #{linescore.dig('teams', 'away', 'runs')}, " \
            "#{home_team.name} #{linescore.dig('teams', 'home', 'runs')}"
        end

        def matchups = Matchups.new(self)

        def media = Media.new(self)

        def probables_and_media = ProbablesAndMedia.new(self)

        def probable_starters = ProbableStarters.new(self)

        def box_score_section = BoxScore.new(self)

        def decisions_section = Decisions.new(self)

        def highlights_section = Highlights.new(self)

        def line_score_section = LineScore.new(self)

        def scoring_plays_section = ScoringPlays.new(self)

        def metadata_section = Metadata.new(self)

        def timestamp
          return super('Game ended') if over?

          return "#{super('Posted')} *Updates start at game time.*" unless @post_id

          return super('Updated') if started?

          super
        end
      end
    end
  end
end

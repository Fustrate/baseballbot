# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar
      module Leaders
        BASE_URL = 'https://bdfed.stitch.mlbinfra.com/bdfed/stats/player?stitch_env=prod&season=%<year>d' \
                   '&group=%<group>s&stats=season&gameType=%<type>s&playerPool=%<pool>s&teamId=%<team_id>d'

        # The data source spells out some of the column names
        COLUMN_ALIASES = {
          'bb' => 'baseOnBalls',
          'h' => 'hits',
          'hld' => 'holds',
          'hr' => 'homeRuns',
          'ip' => 'inningsPitched',
          'r' => 'runs',
          'sb' => 'stolenBases',
          'so' => 'strikeOuts',
          'sv' => 'saves',
          'w' => 'wins',
          'xbh' => 'extraBaseHits'
        }.freeze

        NO_QUALIFIED_PLAYERS = [{ name: 'None Qualified', value: 0 }].freeze

        def hitter_stats(year: nil, type: 'R', count: 1)
          year ||= Date.today.year

          # TODO: I'm not sure this is really memoizing much of anything
          @hitter_stats ||= {}

          @hitter_stats["#{year}-#{type}-#{count}"] ||= load_hitter_stats(year, type, count)
        end

        def pitcher_stats(year: nil, type: 'R', count: 1)
          year ||= Date.today.year

          # TODO: I'm not sure this is really memoizing much of anything
          @pitcher_stats ||= {}

          @pitcher_stats["#{year}-#{type}-#{count}"] ||= load_pitcher_stats(year, type, count)
        end

        def hitter_stats_table(stats: [])
          rows = stats.map { "#{_1.upcase}|#{hitter_stats[_1].first&.values&.join('|')}" }

          <<~TABLE
            Stat|Player|Total
            -|-|-
            #{rows.join("\n")}
          TABLE
        end

        def pitcher_stats_table(stats: [])
          rows = stats.map { "#{_1.upcase}|#{pitcher_stats[_1].first&.values&.join('|')}" }

          <<~TABLE
            Stat|Player|Total
            -|-|-
            #{rows.join("\n")}
          TABLE
        end

        protected

        def load_hitter_stats(year, type, count)
          stats = {}
          all_hitters = load_stats(group: 'hitting', year:, type:)
          qualifying = load_stats(group: 'hitting', year:, type:, pool: 'QUALIFIED')

          %w[h xbh hr rbi bb sb r].each do |key|
            stats[key] = list_of(key, all_hitters, :desc, count, :integer)
          end

          %w[avg obp slg ops].each do |key|
            stats[key] = list_of(key, qualifying, :desc, count, :float)
          end

          stats
        end

        def load_pitcher_stats(year, type, count)
          all_pitchers = load_stats(group: 'pitching', year:, type:)
          qualifying = load_stats(group: 'pitching', year:, type:, pool: 'QUALIFIED')

          stats = { 'ip' => list_of('ip', all_pitchers, :desc, count) }

          %w[w sv hld so].each do |key|
            stats[key] = list_of(key, all_pitchers, :desc, count, :integer)
          end

          %w[whip era avg].each do |key|
            stats[key] = list_of(key, qualifying, :asc, count, :float)
          end

          stats
        end

        def list_of(key, players, direction, count, type = :noop)
          # Always return something that can be used in a template.
          return NO_QUALIFIED_PLAYERS unless players&.any?

          players
            .map { _1.values_at('playerInitLastName', COLUMN_ALIASES[key] || key) }
            .sort_by { _1[1].to_f }
            .send(direction == :desc ? :reverse : :itself)
            .first(count)
            .map { |(name, value)| { name:, value: cast_value(value, type) } }
        end

        def cast_value(value, type)
          return value.to_i if type == :integer
          return pct(value) if type == :float

          value
        end

        def load_stats(group:, year:, type:, pool: 'ALL')
          url = format BASE_URL, year:, pool:, group:, type:, team_id: @subreddit.team.id

          JSON.parse(URI.parse(url).open.read)['stats']
        end

        # Interestingly, this doesn't include the esoteric column "extraBaseHits", and I'd rather not have to add it up
        # myself.
        # def load_from_api(group:, year:, type:, pool:)
        #   @bot.api.stats(
        #     hydrate: 'person',
        #     sportId: 1,
        #     season: year,
        #     group:,
        #     gameType: type,
        #     playerPool: pool,
        #     stats: 'season',
        #     statFields: 'advanced,standard',
        #     teamId: @subreddit.team.id
        #   ).dig('stats', 0, 'splits')
        # end
      end
    end
  end
end

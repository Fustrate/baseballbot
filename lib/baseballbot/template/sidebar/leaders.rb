# frozen_string_literal: true

class Baseballbot
  module Template
    class Sidebar
      module Leaders
        BASE_URL = 'https://bdfed.stitch.mlbinfra.com/bdfed/stats/player?stitch_env=prod' \
                   '&season=%<year>d&sportId=1&stats=season&gameType=%<type>s&limit=25&offset=0' \
                   '&playerPool=%<pool>s&teamId=%<team_id>d'

        HITTER_URL  = "#{BASE_URL}&sortStat=battingAverage&group=hitting&order=desc"
        PITCHER_URL = "#{BASE_URL}&sortStat=earnedRunAverage&group=pitching&order=asc"

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

        def hitter_stats(year: nil, type: 'R', count: 1)
          year ||= Date.today.year

          # TODO: I'm not sure this is really memoizing much of anything
          @hitter_stats ||= {}

          key = [year, type, count].join('-')

          @hitter_stats[key] ||= load_hitter_stats(year, type, count)
        end

        def pitcher_stats(year: nil, type: 'R', count: 1)
          year ||= Date.today.year

          # TODO: I'm not sure this is really memoizing much of anything
          @pitcher_stats ||= {}

          key = [year, type, count].join('-')

          @pitcher_stats[key] ||= load_pitcher_stats(year, type, count)
        end

        def hitter_stats_table(stats: [])
          rows = stats.map do |stat|
            "#{stat.upcase}|#{hitter_stats[stat].first&.values&.join('|')}"
          end

          <<~TABLE
            Stat|Player|Total
            -|-|-
            #{rows.join("\n")}
          TABLE
        end

        def pitcher_stats_table(stats: [])
          rows = stats.map do |stat|
            "#{stat.upcase}|#{pitcher_stats[stat].first&.values&.join('|')}"
          end

          <<~TABLE
            Stat|Player|Total
            -|-|-
            #{rows.join("\n")}
          TABLE
        end

        protected

        def load_hitter_stats(year, type, count)
          stats = {}
          all_hitters = hitters(year: year, type: type)
          qualifying = hitters(year: year, type: type, pool: 'QUALIFIER')

          %w[h xbh hr rbi bb sb r].each do |key|
            stats[key] = list_of(key, all_hitters, :desc, count, :integer)
          end

          %w[avg obp slg ops].each do |key|
            stats[key] = list_of(key, qualifying, :desc, count, :float)
          end

          stats
        end

        def load_pitcher_stats(year, type, count)
          all_pitchers = pitchers(year: year, type: type)
          qualifying = pitchers(year: year, type: type, pool: 'QUALIFIER')

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
          return [{ name: 'None Qualified', value: 0 }] unless players

          source_key = COLUMN_ALIASES[key] || key

          players
            .map { |player| player.values_at 'playerInitLastName', source_key }
            .sort_by { |player| player[1].to_f }
            .send(direction == :desc ? :reverse : :itself)
            .first(count)
            .map { |s| { name: s[0], value: cast_value(s[1], type) } }
        end

        def cast_value(value, type)
          return value.to_i if type == :integer
          return pct(value) if type == :float

          value
        end

        def hitters(year:, type:, pool: 'ALL')
          JSON.parse(open_url(HITTER_URL, year: year, pool: pool, type: type))['stats']
        end

        def pitchers(year:, type:, pool: 'ALL')
          JSON.parse(open_url(PITCHER_URL, year: year, pool: pool, type: type))['stats']
        end

        def open_url(url, **interpolations)
          interpolations[:team_id] = @subreddit.team.id

          URI.parse(format(url, interpolations)).open.read
        end
      end
    end
  end
end

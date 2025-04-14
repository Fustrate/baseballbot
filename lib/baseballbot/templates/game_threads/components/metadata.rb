# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Components
        class Metadata
          include MarkdownHelpers

          def initialize(game_thread)
            @game_thread = game_thread
          end

          def to_s
            <<~MARKDOWN.strip
              #{table(headers: %w[Attendance Weather Wind], rows: [[attendance, weather, wind]])}

              #{umpires_table}
            MARKDOWN
          end

          protected

          def umpires_table
            ump_positions, ump_names = @game_thread.umpires.transform_keys { [it, :center] }.to_a.transpose

            return '' unless ump_positions

            table(headers: ump_positions, rows: [ump_names])
          end

          def attendance = nil

          def weather
            data = @game_thread.game_data['weather'] || {}

            "#{data['temp']}°F, #{data['condition']}" if data['condition']
          end

          def wind = @game_thread.game_data.dig('weather', 'wind')
        end
      end
    end
  end
end

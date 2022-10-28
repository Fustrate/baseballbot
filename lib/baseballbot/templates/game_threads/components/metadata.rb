# frozen_string_literal: true

class Baseballbot
  module Templates
    module GameThreads
      module Components
        class Metadata
          include MarkdownHelpers

          attr_reader :template

          def initialize(template)
            @template = template
          end

          def to_s
            <<~MARKDOWN.strip
              #{table(headers: %w[Attendance Weather Wind], rows: [[attendance, weather, wind]])}

              #{umpires_table}
            MARKDOWN
          end

          protected

          def umpires_table
            ump_positions, ump_names = template.umpires.transform_keys { [_1, :center] }.to_a.transpose

            return '' unless ump_positions

            table(headers: ump_positions, rows: [ump_names])
          end

          def attendance = nil

          def weather
            data = template.game_data['weather'] || {}

            "#{data['temp']}°F, #{data['condition']}" if data['condition']
          end

          def wind = template.game_data.dig('weather', 'wind')
        end
      end
    end
  end
end

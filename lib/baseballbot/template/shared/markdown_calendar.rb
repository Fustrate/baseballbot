# frozen_string_literal: true

class Baseballbot
  module Template
    class Shared
      class MarkdownCalendar
        class << self
          def generate(cells, dates)
            <<~TABLE
              S|M|T|W|T|F|S
              :-:|:-:|:-:|:-:|:-:|:-:|:-:
              #{calendar_rows(cells, dates).join("\n")}
            TABLE
          end

          protected

          def calendar_rows(cells, dates)
            [
              *blank_start(dates.values.first[:date]),
              *cells,
              *blank_end(dates.values.last[:date])
            ].each_slice(7).map { _1.join('|') }
          end

          def blank_start(date)
            [' '] * date.wday
          end

          def blank_end(date)
            [' '] * (6 - date.wday)
          end
        end
      end
    end
  end
end

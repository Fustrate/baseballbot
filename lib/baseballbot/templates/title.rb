# frozen_string_literal: true

require 'mustache'

class Baseballbot
  module Templates
    class Title < Mustache
      def initialize(title, date:)
        super()

        self.template = title

        @date = date
      end

      def to_s
        @to_s ||= @date.strftime(render)
      end

      def year = @date.year

      def month = @date.month

      def day = @date.day

      def month_name = @date.strftime('%B')

      def short_month = @date.strftime('%b')

      def day_of_week = @date.strftime('%A')

      def short_day_of_week = @date.strftime('%a')

      def short_year = @date.strftime('%y')

      def start_time = @date.strftime('%-I:%M %p')
    end
  end
end

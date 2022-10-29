# frozen_string_literal: true

RSpec.describe Baseballbot::Templates::GameThreads::Title do
  before do
    stub_requests! with_response: true
  end

  describe '#to_s' do
    it 'generates a formatting-less title' do
      template = game_thread_template(:preview, title: 'Hello World')

      expect(template.formatted_title).to eq 'Hello World'
    end

    it 'generates a title with date tokens' do
      template = game_thread_template(
        :preview,
        title: '{{month_name}} {{year}}-{{month}}-{{day}} {{short_year}} ' \
               '{{day_of_week}} {{short_month}} {{short_day_of_week}}'
      )

      expect(template.formatted_title).to eq 'July 2022-7-26 22 Tuesday Jul Tue'
    end

    it 'generates a title with time tokens' do
      template = game_thread_template(:preview, title: 'Hello {{start_time}} {{start_time_et}} World')

      expect(template.formatted_title).to eq 'Hello 7:10 PM 10:10 PM ET World'
    end

    it 'interpolates team names' do
      template = game_thread_template(
        :preview,
        title: '{{opponent_name}} {{away_full_name}} {{away_name}} {{home_full_name}} {{home_name}}'
      )

      expect(template.formatted_title).to eq 'Nationals Washington Nationals Nationals Los Angeles Dodgers Dodgers'
    end

    it 'interpolates probable starting pitcher names' do
      template = game_thread_template(:preview, title: 'Hello {{away_pitcher}} {{home_pitcher}} World')

      expect(template.formatted_title).to eq 'Hello Gray, Js White, M World'
    end

    it 'interpolates team records' do
      template = game_thread_template(:preview, title: 'Hello {{away_record}} {{home_record}} World')

      expect(template.formatted_title).to eq 'Hello 55-107 111-51 World'
    end

    it 'interpolates the score after the game has ended' do
      template = game_thread_template(:final, title: 'Hello {{away_runs}} {{home_runs}} World')

      expect(template.formatted_title).to eq 'Hello 4 2 World'
    end

    it 'interpolates postseason series information' do
      template = game_thread_template(:in_progress, title: '{{series_game}}: {{home_wins}} to {{away_wins}}')

      # Since this game is over in real life, yes, they're tied 1 to 1 in game 2.
      expect(template.formatted_title).to eq 'NLCS Game 2: 1 to 1'
    end

    it 'formats simple strftime tokens' do
      template = game_thread_template(:preview, title: '%F %T %-m/%-d/%y %B %A %-I:%M %p')

      expect(template.formatted_title).to eq '2022-07-26 19:10:00 7/26/22 July Tuesday 7:10 PM'
    end
  end
end

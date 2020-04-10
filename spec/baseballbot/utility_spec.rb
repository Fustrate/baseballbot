# frozen_string_literal: true

RSpec.describe Baseballbot::Utility do
  describe '#parse_time_zone' do
    it 'recognizes a correct time zone' do
      expect(
        described_class.parse_time_zone('America/New_York').friendly_identifier
      ).to eq 'America - New York'
    end

    it 'falls back to Los Angeles' do
      expect(
        described_class.parse_time_zone('America/Paris').friendly_identifier
      ).to eq 'America - Los Angeles'
    end
  end

  describe '#parse_time' do
    it 'parses a normal time with a string time zone' do
      tz = 'America/Los_Angeles'

      expect(
        described_class.parse_time('2020-04-09T15:00:00Z', in_time_zone: tz)
      ).to eq Time.parse('2020-04-09T08:00:00 PDT')
    end

    it 'parses a normal time with a time zone object' do
      tz = TZInfo::Timezone.get 'America/Chicago'

      expect(
        described_class.parse_time('2019-11-09T15:00:00Z', in_time_zone: tz)
      ).to eq Time.parse('2019-11-09T09:00:00 CST')
    end
  end

  describe '#adjust_time_proc' do
    it 'adjust with an integer offset' do
      start = Time.parse('2019-04-09T12:00:00 PDT')

      results = {
        '-3' => '2019-04-09T09:00:00 PDT',
        '3' => '2019-04-09T09:00:00 PDT',
        '1' => '2019-04-09T11:00:00 PDT'
      }

      results.each do |offset, target|
        expect(described_class.adjust_time_proc(offset).call(start))
          .to eq Time.parse(target)
      end
    end

    # The absolute time is tested in its own method - just make sure it's called
    it 'adjust with an absolute time' do
      expect(described_class).to receive(:constant_time).exactly(2).times

      described_class.adjust_time_proc('7am')
      described_class.adjust_time_proc('6:45 AM')
    end

    it 'defaults to 3 hours' do
      start = Time.parse('2019-04-09T12:00:00 PDT')
      target = Time.parse('2019-04-09T09:00:00 PDT')

      ['', nil].each do |offset|
        expect(described_class.adjust_time_proc(offset).call(start))
          .to eq target
      end
    end
  end

  describe '#constant_time' do
    it 'does a thing' do
      start = Time.parse('2019-04-09T12:34:56 PDT')

      results = {
        [nil, '7', nil, 'am'] => '2019-04-09T07:00:00 PDT',
        [nil, '6', ':45', 'AM'] => '2019-04-09T06:45:00 PDT'
      }

      results.each do |match_data, target|
        expect(described_class.constant_time(match_data).call(start))
          .to eq Time.parse(target)
      end
    end
  end
end

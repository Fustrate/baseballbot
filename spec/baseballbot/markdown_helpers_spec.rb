# frozen_string_literal: true

class TestSubject
  include Baseballbot::MarkdownHelpers
end

RSpec.describe Baseballbot::MarkdownHelpers do
  let(:template) { TestSubject.new }

  describe '#table' do
    it 'generates a markdown table with headers and rows' do
      result = template.table(
        headers: [['Name', :left], ['Age', :center], ['Score', :right]],
        rows: [%w[Alice 25 100], %w[Bob 30 95]]
      )

      expected = <<~MARKDOWN.strip
        |Name|Age|Score|
        |-|:-:|-:|
        |Alice|25|100|
        |Bob|30|95|
      MARKDOWN

      expect(result).to eq expected
    end

    it 'generates a markdown table with default left alignment' do
      result = template.table(
        headers: %w[Name Age],
        rows: [%w[Alice 25]]
      )

      expected = <<~MARKDOWN.strip
        |Name|Age|
        |-|-|
        |Alice|25|
      MARKDOWN

      expect(result).to eq expected
    end

    it 'generates a markdown table with empty rows' do
      result = template.table(headers: %w[Col1 Col2], rows: [])

      expected = <<~MARKDOWN.strip
        |Col1|Col2|
        |-|-|
        ||
      MARKDOWN

      expect(result).to eq expected
    end
  end

  describe '#markdown_calendar' do
    it 'generates a calendar table' do
      dates = {
        '1' => { date: Date.new(2024, 1, 1) },  # Monday
        '7' => { date: Date.new(2024, 1, 7) }   # Sunday
      }
      cells = %w[1 2 3 4 5 6 7]

      result = template.markdown_calendar(cells, dates)

      expect(result).to include('|S|M|T|W|T|F|S|')
      expect(result).to include('|:-:|:-:|:-:|:-:|:-:|:-:|:-:|')
    end
  end

  describe '#calendar_rows' do
    it 'pads calendar rows with spaces for first week' do
      dates = {
        '1' => { date: Date.new(2024, 1, 3) },  # Wednesday (wday = 3)
        '2' => { date: Date.new(2024, 1, 4) }   # Thursday
      }
      cells = %w[1 2]

      rows = template.send(:calendar_rows, cells, dates).to_a

      expect(rows.first[0..2]).to eq [' ', ' ', ' ']
      expect(rows.first[3..4]).to eq %w[1 2]
    end
  end
end

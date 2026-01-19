# frozen_string_literal: true

class Baseballbot
  module Sidebars
    def update_sidebars!(names: [])
      names = names.map(&:downcase)

      sequel[:subreddits].where(Sequel.lit("options['sidebar']['enabled']::boolean IS TRUE")).order(:id).each do |row|
        next unless names.empty? || names.include?(row[:name].downcase)

        update_sidebar! name_to_subreddit(subreddits[row[:name]])
      end
    end

    def update_sidebar!(subreddit)
      Honeybadger.context(subreddit: subreddit.name)

      subreddit.modify_settings description: generate_sidebar(subreddit)
    end

    def show_sidebar(name) = generate_sidebar(name_to_subreddit(name))

    protected

    def generate_sidebar(subreddit)
      raise Baseballbot::Error::NoSidebarText unless sidebar_present?(subreddit)

      Templates::Sidebar
        .new(**subreddit.template_for('sidebar'), subreddit:)
        .replace_in CGI.unescapeHTML(subreddit.settings[:description])
    end

    def sidebar_present?(subreddit)
      subreddit.settings && subreddit.settings[:description] && !subreddit.settings[:description].strip.empty?
    end
  end
end

# frozen_string_literal: true

class Baseballbot
  module Models
    class Edit < Sequel::Model(:edits)
      many_to_one :user, class: 'Baseballbot::Models::User', key: :user_id
      many_to_one :system_user, class: 'Baseballbot::Models::SystemUser', key: :user_id
      many_to_one :subreddit, class: 'Baseballbot::Models::Subreddit', key: :editable_id
      many_to_one :game_thread, class: 'Baseballbot::Models::GameThread', key: :editable_id

      def actor = user_type == 'SystemUser' ? system_user : user

      def editable
        case editable_type
        when 'Subreddit' then subreddit
        when 'GameThread' then game_thread
        end
      end
    end
  end
end

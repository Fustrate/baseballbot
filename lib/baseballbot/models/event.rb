# frozen_string_literal: true

class Baseballbot
  module Models
    class Event < Sequel::Model(:events)
      many_to_one :user, class: 'Baseballbot::Models::User', key: :user_id
      many_to_one :system_user, class: 'Baseballbot::Models::SystemUser', key: :user_id

      def actor = user_type == 'SystemUser' ? system_user : user
    end
  end
end

class Visit < ApplicationRecord
  has_many :ahoy_events, class_name: 'Ahoy::Event'
  belongs_to :user, polymorphic: true
  belongs_to :logged_in_user, -> { where(visits: { user_type: 'User' }) }, class_name: 'User', foreign_key: 'user_id'
  belongs_to :founder, -> { where(visits: { user_type: 'Founder' }) }, foreign_key: 'user_id'

  scope :user_visits, -> { joins(:logged_in_user) }
  scope :last_week, -> { where('started_at > ?', 1.week.ago.beginning_of_day) }
end

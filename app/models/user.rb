class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :inventories, dependent: :destroy
  has_many :items, dependent: :destroy
        
  validates :username, presence: true, uniqueness: true
  validates :locale, inclusion: { in: %w[en de] }
  validates :theme, inclusion: { in: %w[light dark] }
  def active_for_authentication?
    super && !blocked?
  end

  def inactive_message
    blocked? ? :locked : super
  end
end
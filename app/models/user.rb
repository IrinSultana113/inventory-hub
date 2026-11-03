class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: true
  validates :locale, inclusion: { in: %w[en de] }
  validates :theme, inclusion: { in: %w[light dark] }
end
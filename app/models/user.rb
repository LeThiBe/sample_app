class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: Settings.user.email_length},
  format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :password, presence: true, length: {minimum: Settings.user.password_length}
  validates :name, presence: true, length: {maximum: Settings.user.name_length}
  before_save{email.downcase!}
  has_secure_password
  # Returns the hash digest of the given string.
  def self.digest string
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : Crypt::Engine.cost
    BCrypt::Password.create string, cost: cost
  end
end

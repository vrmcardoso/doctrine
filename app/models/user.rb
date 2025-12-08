class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :campaigns, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # 2. Validate: Ensure it looks like an email and is unique
  validates :email_address, presence: true,
                            uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP, message: "is invalid" }
end

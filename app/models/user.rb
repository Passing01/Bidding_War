class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_secure_password

  validates :username, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }, if: :password
  validates :password, format: { with: /\A(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+\z/, message: "must include at least one uppercase letter, one number, and one special character" }, if: :password
  validates :password_confirmation, presence: true, if: :password
  validates :phone_number, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true
  validates :country, presence: true
  validates :user_type, presence: true
  validates :terms_of_service, acceptance: true

  has_many :items, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_many :transactions, dependent: :destroy
end

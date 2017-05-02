class Lecture < ApplicationRecord
  has_many :checks, dependent: :destroy
  has_many :users, through: :checks
end

# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :event

  has_many :tickets
end

# frozen_string_literal: true

class Payment < ApplicationRecord
  validates :paid_amount, presence: true
  validates :paid_amount, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validate :event_datetime, on: :create
  validate :change_is_left, on: :create

  belongs_to :user
  belongs_to :event

  has_many :tickets

  private

  def event_datetime
    errors.add(:base, "can not buy a ticket after the event") if DateTime.now > event.happens_at
  end

  def change_is_left
    errors.add(:base, "can not buy an equal number of tickets, change is left") unless paid_amount % event.ticket_price == 0
  end

  # Dodaj walidacje:
  # user kupił 1 bilet (bilety są dostępne, stać go i jest przed koncertem),
  # user kupił wiele biletów, (bilety są dostępne, stać go i jest przed koncertem),

  # jak user chce kupić 3 bilety a jest 1,
  # jak user chce kupić 3 bilety a jest 0,

  # jak user nie ma żadnych pieniędzy,
  # jak user nie ma wystarczająco dużo pieniędzy,

  # jak nie wyslal wielokrotnosci ceny biletu,

  # wysylana kwota zaczyna się od zera?
end

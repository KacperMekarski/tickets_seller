# frozen_string_literal: true

class RemoveReferenceFromTickets < ActiveRecord::Migration[6.0]
  def change
    remove_reference(:tickets, :event, index: true, foreign_key: true)
  end
end

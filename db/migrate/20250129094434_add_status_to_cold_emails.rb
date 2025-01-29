# frozen_string_literal: true

class AddStatusToColdEmails < ActiveRecord::Migration[8.0]
  def change
    add_column :cold_emails, :status, :string, default: 'pending'
    add_column :cold_emails, :error_message, :text
  end
end

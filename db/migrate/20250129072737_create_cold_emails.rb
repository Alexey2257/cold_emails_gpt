# frozen_string_literal: true

class CreateColdEmails < ActiveRecord::Migration[8.0]
  def change
    create_table :cold_emails do |t|
      t.string :subject
      t.text :body

      t.timestamps
    end
  end
end

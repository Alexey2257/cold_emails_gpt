# frozen_string_literal: true

class ColdEmailForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  LANGUAGES = %w[english spanish french].freeze
  STYLES = %w[sales friendly formal].freeze
  LENGTHS = %w[short medium long].freeze

  attribute :purpose, :string
  attribute :recipient, :string
  attribute :sender, :string
  attribute :prompt, :string
  attribute :language, :string, default: 'english'
  attribute :style, :string, default: 'professional'
  attribute :length, :string, default: 'medium'

  validates :purpose, presence: true, length: { minimum: 1, maximum: 500 }
  validates :recipient, presence: true, length: { minimum: 1, maximum: 500 }
  validates :sender, presence: true, length: { minimum: 1, maximum: 500 }
  validates :prompt, length: { maximum: 1000 }
  validates :language, inclusion: { in: LANGUAGES }
  validates :style, inclusion: { in: STYLES }
  validates :length, inclusion: { in: LENGTHS }

  def initialize(attributes = {})
    super
    @cold_email = ColdEmail.new
  end

  def save
    return false unless valid?

    success = false

    ActiveRecord::Base.transaction do
      @cold_email.status = 'pending'
      @cold_email.save!
      success = true
    end

    if success
      # Move perform_async outside the transaction
      ColdEmailGenerationJob.perform_async(
        @cold_email.id,
        attributes.slice(
          'purpose',
          'recipient',
          'sender',
          'prompt',
          'language',
          'style',
          'length'
        )
      )
    end

    true
  rescue StandardError => e
    errors.add(:base, "Failed to queue email generation: #{e.message}")
    false
  end

  attr_reader :cold_email

  private

  def generate_email
    ColdEmailGenerator.new(
      purpose: purpose,
      recipient: recipient,
      sender: sender,
      prompt: prompt,
      options: {
        language: language,
        style: style,
        length: length
      }
    ).call
  end
end

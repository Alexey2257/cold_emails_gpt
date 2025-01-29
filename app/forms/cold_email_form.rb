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

    ActiveRecord::Base.transaction do
      result = generate_email
      return false unless result

      @cold_email.subject = result[:subject]
      @cold_email.body = result[:body]
      @cold_email.save!
    end

    true
  rescue StandardError => e
    errors.add(:base, "Failed to generate email: #{e.message}")
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

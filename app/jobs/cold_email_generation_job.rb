# frozen_string_literal: true

# app/jobs/cold_email_generation_job.rb
class ColdEmailGenerationJob
  include Sidekiq::Job

  def perform(cold_email_id, form_attributes)
    @cold_email = ColdEmail.find(cold_email_id)
    @form_attributes = form_attributes

    generate_and_update_email
    broadcast_update
  end

  private

  def generate_and_update_email
    result = generate_email
    update_cold_email(result)
  end

  def generate_email
    ColdEmailGenerator.new(
      purpose: @form_attributes['purpose'],
      recipient: @form_attributes['recipient'],
      sender: @form_attributes['sender'],
      prompt: @form_attributes['prompt'],
      options: generator_options
    ).call
  end

  def generator_options
    {
      language: @form_attributes['language'],
      style: @form_attributes['style'],
      length: @form_attributes['length']
    }
  end

  def update_cold_email(result)
    @cold_email.update!(
      subject: result[:subject],
      body: result[:body],
      status: 'completed'
    )
  end

  def broadcast_update
    Turbo::StreamsChannel.broadcast_replace_to(
      broadcast_channel,
      target: 'email-preview',
      partial: 'cold_emails/cold_email',
      locals: { cold_email: @cold_email }
    )
  end

  def broadcast_channel
    "cold_email_#{@cold_email.id}"
  end
end

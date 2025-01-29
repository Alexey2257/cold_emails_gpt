# app/jobs/cold_email_generation_job.rb
class ColdEmailGenerationJob
  include Sidekiq::Job

  def perform(cold_email_id, form_attributes)
    cold_email = ColdEmail.find(cold_email_id)

    result = ColdEmailGenerator.new(
      purpose: form_attributes['purpose'],
      recipient: form_attributes['recipient'],
      sender: form_attributes['sender'],
      prompt: form_attributes['prompt'],
      options: {
        language: form_attributes['language'],
        style: form_attributes['style'],
        length: form_attributes['length']
      }
    ).call

    cold_email.update!(
      subject: result[:subject],
      body: result[:body],
      status: 'completed'
    )

    # Broadcasting with correct targeting
    Turbo::StreamsChannel.broadcast_replace_to(
      "cold_email_#{cold_email.id}",
      target: "email-preview",
      partial: "cold_emails/cold_email",
      locals: { cold_email: cold_email }
    )
  end
end

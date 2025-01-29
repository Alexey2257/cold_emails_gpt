# frozen_string_literal: true

require 'openai'

# frozen_string_literal: true
class ColdEmailGenerator
  SYSTEM_MESSAGE = <<~PROMPT.freeze
    You are an expert cold email writer with extensive experience in business development, sales, and professional communication.#{' '}
    Your expertise includes:
    - Writing compelling subject lines that increase open rates
    - Creating personalized content that demonstrates research and understanding
    - Crafting clear value propositions
    - Implementing effective calls-to-action
    - Following email best practices for deliverability

    Guidelines for email creation:
    1. Subject lines should be attention-grabbing but not clickbait (4-7 words)
    2. Opening line must be personalized based on recipient information
    3. Body should follow AIDA framework:
       - Attention: Hook the reader
       - Interest: Build curiosity
       - Desire: Show clear value
       - Action: Clear next step
    4. Length should be appropriate for the context (typically 2-3 short paragraphs)
    5. Tone should match the specified style while remaining professional

    Response must be a JSON object with:
    {
      "subject": "The email subject line",
      "body": "The email body content",
    }
  PROMPT

  def initialize(purpose:, recipient:, sender:, prompt: nil, options: {})
    @purpose = purpose
    @recipient = recipient
    @sender = sender
    @prompt = prompt
    @language = options[:language]
    @style = normalize_style(options[:style])
    @length = normalize_length(options[:length])
  end

  def call
    response = client.chat(parameters: {
                             model: 'gpt-4o-mini',
                             messages: messages,
                             response_format: { type: 'json_object' }
                           })

    parse_response(response)
  rescue StandardError => e
    Rails.logger.error("Cold email generation failed: #{e.message}")
    Rails.logger.error("messages: #{messages}")
    nil
  end

  private

  def client
    @client ||= OpenAI::Client.new(
      access_token: Rails.application.credentials.dig(:openai, :access_token)
    )
  end

  def messages
    [
      { role: 'system', content: SYSTEM_MESSAGE },
      { role: 'user', content: user_message }
    ]
  end

  def normalize_style(style)
    {
      'sales' => 'sales: enthusiastic and persuasive tone that emphasizes value and benefits',
      'friendly' => 'friendly: warm and conversational while maintaining professionalism',
      'formal' => 'formal: structured and traditional communication with proper etiquette'
    }[style]
  end

  def normalize_length(length)
    {
      'short' => 'under 100 words',
      'medium' => '100-150 words',
      'long' => '150-250 words'
    }[length]
  end

  def user_message
    <<~MESSAGE
      Generate a cold email in JSON format with 'subject' and 'body' keys based on:

      Purpose: #{@purpose}
      Recipient: #{@recipient}
      Sender: #{@sender}

      Requirements:
      - Language: #{@language}
      - Style: #{@style}
      - Length: #{@length}

      #{prompt_section}
    MESSAGE
  end

  def prompt_section
    "Additional Instructions:\n#{@prompt}"
  end

  def parse_response(response)
    content = response.dig('choices', 0, 'message', 'content')
    return nil if content.blank?

    JSON.parse(content, symbolize_names: true)
  rescue JSON::ParseError => e
    Rails.logger.error("Failed to parse JSON response: #{e.message}")
    nil
  end
end

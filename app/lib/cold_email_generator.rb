# frozen_string_literal: true

require 'openai'

# frozen_string_literal: true
class ColdEmailGenerator
  SYSTEM_MESSAGE = <<~PROMPT
    You are an expert cold email writer. Create a personalized cold email that is
    concise, engaging, and includes a clear call-to-action.
    Follow the specified style, language, and length requirements.
    Always respond in JSON format with 'subject' and 'body' keys.
  PROMPT

  def initialize(purpose:, recipient:, sender:, prompt: nil, options: {})
    @purpose = purpose
    @recipient = recipient
    @sender = sender
    @prompt = prompt
    @language = options[:language] || 'english'
    @style = options[:style] || 'professional'
    @length = options[:length] || 'medium'
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

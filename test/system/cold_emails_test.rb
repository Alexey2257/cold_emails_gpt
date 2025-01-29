# frozen_string_literal: true

require 'application_system_test_case'

class ColdEmailsTest < ApplicationSystemTestCase
  setup do
    @cold_email = cold_emails(:one)
  end

  test 'visiting the index' do
    visit cold_emails_url
    assert_selector 'h1', text: 'Cold emails'
  end

  test 'should update Cold email' do
    visit cold_email_url(@cold_email)
    click_on 'Edit this cold email', match: :first

    fill_in 'Body', with: @cold_email.body
    fill_in 'Subject', with: @cold_email.subject
    click_on 'Update Cold email'

    assert_text 'Cold email was successfully updated'
    click_on 'Back'
  end

  test 'should destroy Cold email' do
    visit cold_email_url(@cold_email)
    click_on 'Destroy this cold email', match: :first

    assert_text 'Cold email was successfully destroyed'
  end
end

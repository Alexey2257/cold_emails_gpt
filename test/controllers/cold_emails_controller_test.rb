# frozen_string_literal: true

require 'test_helper'

class ColdEmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cold_email = cold_emails(:one)
  end

  test 'should get index' do
    get cold_emails_url
    assert_response :success
  end

  test 'should get new' do
    get new_cold_email_url
    assert_response :success
  end

  test 'should create cold_email' do
    assert_difference('ColdEmail.count') do
      post cold_emails_url, params: { cold_email: { body: @cold_email.body, subject: @cold_email.subject } }
    end

    assert_redirected_to cold_email_url(ColdEmail.last)
  end

  test 'should show cold_email' do
    get cold_email_url(@cold_email)
    assert_response :success
  end

  test 'should get edit' do
    get edit_cold_email_url(@cold_email)
    assert_response :success
  end

  test 'should destroy cold_email' do
    assert_difference('ColdEmail.count', -1) do
      delete cold_email_url(@cold_email)
    end

    assert_redirected_to cold_emails_url
  end
end

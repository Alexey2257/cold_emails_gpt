# frozen_string_literal: true

class ColdEmailsController < ApplicationController
  before_action :set_cold_email, only: %i[show edit update destroy]

  def index
    @cold_emails = ColdEmail.all
  end

  def show; end

  def new
    @cold_email = ColdEmail.new
  end

  def edit; end

  def create
    @cold_email = ColdEmail.new

    result = ::ColdEmailGenerator.new(
      purpose: params[:cold_email][:purpose],
      recipient: params[:cold_email][:recipient],
      sender: params[:cold_email][:sender],
      prompt: params[:cold_email][:prompt],
      options: {
        language: params[:cold_email][:language],
        style: params[:cold_email][:style],
        length: params[:cold_email][:length]
      }
    ).call

    if result
      @cold_email.subject = result[:subject]
      @cold_email.body = result[:body]

      if @cold_email.save
        redirect_to @cold_email, notice: 'Cold email was successfully generated and saved.'
      else
        render :new, status: :unprocessable_entity
      end
    else
      @cold_email.errors.add(:base, 'Failed to generate email. Please try again.')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    respond_to do |format|
      if @cold_email.update(cold_email_params)
        format.html { redirect_to @cold_email, notice: 'Cold email was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @cold_email.destroy!

    respond_to do |format|
      format.html { redirect_to cold_emails_path, notice: 'Cold email was successfully destroyed.' }
    end
  end

  private

  def set_cold_email
    @cold_email = ColdEmail.find(params[:id])
  end

  def cold_email_params
    params.require(:cold_email).permit(:subject, :body)
  end
end

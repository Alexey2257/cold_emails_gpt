# frozen_string_literal: true

class ColdEmailsController < ApplicationController
  before_action :set_cold_email, only: %i[show edit update destroy]

  def index
    @cold_emails = ColdEmail.all
  end

  def show; end

  def new
    @form = ::ColdEmailForm.new
  end

  def edit; end

  def create
    @form = ::ColdEmailForm.new(cold_email_form_params)

    if @form.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update('email-preview',
                                                   partial: 'cold_emails/cold_email',
                                                   locals: { cold_email: @form.cold_email })
        end
        format.html { redirect_to @form.cold_email }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('cold-email-form',
                                partial: 'form',
                                locals: { form: @form }),
            turbo_stream.update('email-preview',
                                partial: 'empty_state')
          ]
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @cold_email.update(update_params)
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

  def cold_email_form_params
    params.require(:cold_email_form).permit(
      :purpose,
      :recipient,
      :sender,
      :prompt,
      :language,
      :style,
      :length
    )
  end

  def update_params
    params.require(:cold_email).permit(
      :subject,
      :body
    )
  end
end

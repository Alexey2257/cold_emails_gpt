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
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # Todo, regeneration
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
end

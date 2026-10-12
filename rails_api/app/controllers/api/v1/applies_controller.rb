class Api::V1::AppliesController < ApplicationController
  before_action :set_apply, only: %i[show update destroy mark_read invite]

  def index
    applies = apply_scope
    applies = applies.where(read: boolean_param(params[:read])) if params.key?(:read)
    applies = applies.where(invited: boolean_param(params[:invited])) if params.key?(:invited)
    render json: applies.order(:id)
  end

  def show
    render json: @apply
  end

  def create
    apply = Apply.create!(apply_params)
    render json: apply, status: :created
  end

  def update
    @apply.update!(apply_params)
    render json: @apply
  end

  def mark_read
    @apply.update!(read: true)
    render json: @apply
  end

  def invite
    @apply.update!(read: true, invited: true)
    render json: @apply
  end

  def destroy
    @apply.destroy!
    head :no_content
  end

  private

  def apply_scope
    applies = Apply.all
    if params[:job_id].present?
      jobs = params[:company_id].present? ? Company.active.find(params[:company_id]).jobs.active : Job.active
      job = jobs.find(params[:job_id])
      applies = applies.where(job_id: job.id)
    elsif params[:company_id].present?
      company = Company.active.find(params[:company_id])
      applies = applies.where(job_id: company.jobs.active.select(:id))
    end
    if params[:geek_id].present?
      geek = Geek.find(params[:geek_id])
      applies = applies.where(geek_id: geek.id)
    end
    applies
  end

  def set_apply
    @apply = Apply.find(params[:id])
  end

  def apply_params
    fields = params.permit(:job_id, :geek_id, :read, :invited)
    job_id = request.path_parameters[:job_id]
    if job_id.present?
      jobs = params[:company_id].present? ? Company.active.find(params[:company_id]).jobs.active : Job.active
      fields[:job_id] = jobs.find(job_id).id
    end
    geek_id = request.path_parameters[:geek_id]
    fields[:geek_id] = Geek.find(geek_id).id if geek_id.present?
    %i[read invited].each do |field|
      fields[field] = boolean_param(fields[field]) if fields.key?(field)
    end
    fields
  end
end

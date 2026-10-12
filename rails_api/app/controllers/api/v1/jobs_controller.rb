class Api::V1::JobsController < ApplicationController
  before_action :set_job, only: %i[show update destroy]

  def index
    jobs = filter_text(job_scope, :name)
    jobs = filter_text(jobs, :place)
    render json: jobs.order(:id)
  end

  def show
    render json: @job
  end

  def create
    job = Job.new(job_params)
    company_id = request.path_parameters[:company_id]
    job.company = Company.active.find(company_id) if company_id.present?
    job.save!
    render json: job, status: :created
  end

  def update
    @job.update!(job_params)
    render json: @job
  end

  def destroy
    @job.mark_deleted!
    head :no_content
  end

  private

  def job_scope
    company_id = request.path_parameters[:company_id]
    company_id ||= identifier_param(:company_id) if action_name == "index"
    company_id.present? ? Company.active.find(company_id).jobs.active : Job.active
  end

  def set_job
    @job = job_scope.find(params[:id])
  end

  def job_params
    fields = request.path_parameters[:company_id].present? ? %i[name place] : %i[name place company_id]
    params.permit(*fields)
  end
end

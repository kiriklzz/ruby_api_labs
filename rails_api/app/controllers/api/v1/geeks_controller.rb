class Api::V1::GeeksController < ApplicationController
  before_action :set_geek, only: %i[show update destroy resume]

  def index
    geeks = Geek.all
    if params[:job_id].present?
      jobs = params[:company_id].present? ? Company.active.find(params[:company_id]).jobs.active : Job.active
      job = jobs.find(params[:job_id])
      geeks = geeks.joins(:applies).where(applies: { job_id: job.id }).distinct
    elsif params[:company_id].present?
      company = Company.active.find(params[:company_id])
      geeks = geeks.joins(:applies).where(applies: { job_id: company.jobs.active.select(:id) }).distinct
    end
    geeks = filter_text(geeks, :name)
    geeks = filter_text(geeks, :stack)
    render json: geeks.order(:id)
  end

  def show
    render json: @geek
  end

  def create
    geek = Geek.create!(geek_params)
    render json: geek, status: :created
  end

  def update
    @geek.update!(geek_params)
    render json: @geek
  end

  def resume
    @geek.update!(params.permit(:resume))
    render json: @geek
  end

  def destroy
    @geek.destroy!
    head :no_content
  end

  private

  def set_geek
    @geek = Geek.find(params[:id])
  end

  def geek_params
    params.permit(:name, :stack, :resume)
  end
end

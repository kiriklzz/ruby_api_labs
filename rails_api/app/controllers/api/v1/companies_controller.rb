class Api::V1::CompaniesController < ApplicationController
  before_action :set_company, only: %i[show update destroy]

  def index
    companies = filter_text(Company.active, :name)
    companies = filter_text(companies, :location)
    render json: companies.order(:id)
  end

  def show
    render json: @company
  end

  def create
    company = Company.create!(company_params)
    render json: company, status: :created
  end

  def update
    @company.update!(company_params)
    render json: @company
  end

  def destroy
    @company.mark_deleted!
    head :no_content
  end

  def mark_deleted
    company = Company.find(params[:id])
    company.mark_deleted! unless company.deleted?
    render json: company
  end

  private

  def set_company
    @company = Company.active.find(params[:id])
  end

  def company_params
    params.permit(:name, :location)
  end
end

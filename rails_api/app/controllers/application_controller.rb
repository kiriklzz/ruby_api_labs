class ApplicationController < ActionController::API
  include ActionController::Serialization

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Record not found", status: "not_found" }, status: :not_found
  end

  rescue_from ActiveRecord::RecordInvalid do |error|
    render json: { errors: error.record.errors.to_hash }, status: :unprocessable_entity
  end

  rescue_from ActiveRecord::RecordNotDestroyed do |error|
    render json: { errors: error.record.errors.to_hash }, status: :unprocessable_entity
  end

  rescue_from ActionController::BadRequest do |error|
    render json: { error: error.message }, status: :bad_request
  end

  def catch_404
    render json: { error: "No route matches", status: "no_route" }, status: :not_found
  end

  private

  def identifier_param(field)
    value = params[field]
    return value if value.nil? || value.is_a?(String) || value.is_a?(Integer)

    raise ActionController::BadRequest, "#{field} must be a scalar identifier"
  end

  def filter_text(records, field)
    return records if params[field].blank?

    value = ActiveRecord::Base.sanitize_sql_like(params[field].to_s)
    records.where("#{records.klass.table_name}.#{field} ILIKE ?", "%#{value}%")
  end

  def boolean_param(value)
    case value
    when true, "true"
      true
    when false, "false"
      false
    else
      raise ActionController::BadRequest, "Expected true or false"
    end
  end
end

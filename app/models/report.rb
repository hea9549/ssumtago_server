class Report
  include Mongoid::Document
  field :_id, type: String, default: -> {nil}
  field :surveyId, as: :survey_id, type: Integer
  field :modelId, as: :model_id, type: Integer
  field :version, type: String
  field :requestTime, as: :request_time, type: DateTime
  field :responseTime, as: :response_time, type: DateTime
  field :isProcessed, as: :is_processed, type: Boolean
  field :result, type: Array
  embedded_in :user
  embeds_many :data, class_name:"Ssumji"
end

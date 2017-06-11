# User의 predictReports를 담당하는 Report 모델 클래스
class Report
  include Mongoid::Document
  field :surveyId, as: :survey_id, type: Integer
  field :modelId, as: :model_id, type: Integer
  field :version, type: String
  field :requestTime, as: :request_time, type: DateTime
  field :responseTime, as: :response_time, type: DateTime
  field :isProcessed, as: :is_processed, type: Boolean
  field :result, type: Array
  # User 모델에 embeded됨
  embedded_in :user
  # Ssumji 모델을 embed함
  embeds_many :data, class_name:"Ssumji"
  # surveyId, modelId, version 존재해야함
  # validates_presence_of :surveyId
  # validates_presence_of :modelId
  # validates_presence_of :version
end

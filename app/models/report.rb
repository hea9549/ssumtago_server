class Report
  include Mongoid::Document
  field :_id, type: String, default: -> {nil}
  field :surveyId, as: :survey_id, type: Integer
  field :modelId, as: :model_id, type: Integer
  field :result, type: Float
  field :version, type: String
  embedded_in :user
  embeds_many :data, class_name:"Ssumji"
end

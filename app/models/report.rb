class Report
  include Mongoid::Document
  field :surveyId, as: :survey_id, type: Integer
  field :modelId, as: :model_id, type: Integer
  field :version, type: String
  embedded_in :user
  embeds_many :data, class_name:"Ssumji"
end

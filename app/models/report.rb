class Report
  include Mongoid::Document
  # Mongoid.embedded_object_id = false
  field :surveyId, as: :survey_id, type: Integer
  field :modelId, as: :model_id, type: Integer
  field :version, type: String
  embedded_in :user
  embeds_many :data, class_name:"Ssumji"
  def identify
  end
end

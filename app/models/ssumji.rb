class Ssumji
  include Mongoid::Document
  # Mongoid.embedded_object_id = false
  field :questionCode, as: :question_code, type: String
  field :answerCode, as: :answer_code, type: String
  embedded_in :report
  def identify
  end

end

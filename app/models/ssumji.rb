class Ssumji
  include Mongoid::Document
  field :_id, type: String, default: -> {nil}
  field :questionCode, as: :question_code, type: String
  field :answerCode, as: :answer_code, type: String
  embedded_in :report

end

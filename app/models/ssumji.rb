# Report에 data 담당하는 Ssumji 모델 클래스
class Ssumji
  include Mongoid::Document
  # objectId 값 nil
  field :_id, type: String, default: -> {nil}
  field :questionCode, as: :question_code, type: String
  field :answerCode, as: :answer_code, type: String
  # Report 모델에 embeded됨
  embedded_in :report
end

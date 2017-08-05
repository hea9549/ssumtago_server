# Survey를 담당하는 Survey 모델 클래스
class Survey
  include Mongoid::Document
  field :models, type: Array, default: []
  field :name, type: String
  field :questions, type: Array, default: []
  field :excludeCodes, type: Array, default: []
  field :answerCodes, type: String
  field :version, type: String
  field :surveyId, type: Integer
  field :desc, type: String
  field :isAvailable, as: :is_available, type: Boolean
  field :parameters, type: Object, default: {}

  # _id를 id로 수정
  def as_json(*args)
    res = super
    res["id"] = res.delete("_id").to_s
    res
  end
end

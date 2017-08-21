# User의 이전 설문지를 담당하는 PreviousReport 모델 클래스
class PreviousReport
  include Mongoid::Document
  field :surveyId2, as: :survey_id2, type: Integer
  field :requestTime, as: :request_time, type: DateTime
  field :userId, as: :user_id, type: String
  field :startTime, as: :start_time, type: DateTime
  field :endTime, as: :end_time, type: DateTime
  embeds_many :data, class_name:"Ssumji"

  # _id를 id로 수정
  def as_json(*args)
    res = super
    res["id"] = res.delete("_id").to_s
    res
  end
end

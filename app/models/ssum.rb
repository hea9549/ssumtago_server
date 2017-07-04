# User의 ssums를 담당하는 Ssum 모델 클래스
class Ssum
  include Mongoid::Document
  # created_at / updated_at column 추가
  include Mongoid::Timestamps
  field :name, type: String
  field :age, type: String
  field :sex, type: String
  field :startDate, type: String
  field :isFavorite, type: Boolean, default: false
  # User 모델에 embeded됨
  embedded_in :user
  # Report 모델을 embed함
  embeds_many :predictReports, class_name:"Report"
  # name, age, sex값이 존재해야함
  validates_presence_of :name
  validates_presence_of :age
  validates_presence_of :sex

  # _id를 id로 수정
  def as_json(*args)
    res = super
    res["id"] = res.delete("_id").to_s
    res
  end
end

# User의 ssums를 담당하는 Ssum 모델 클래스
class Ssum
  include Mongoid::Document
  # created_at / updated_at column 추가
  include Mongoid::Timestamps
  field :name, type: String
  field :age, type: String
  field :sex, type: String
  # User 모델에 embeded됨
  embedded_in :user
  # Report 모델을 embed함
  embeds_many :predictReports, class_name:"Report"
end

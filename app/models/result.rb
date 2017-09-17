class Result
  include Mongoid::Document
  # objectId 값 nil
  field :_id, type: String, default: -> {nil}
  field :type, type: String
  field :results, type: Array
  embedded_in :report
  # 20170909 score로 할지 result로 할지 고민 중
  # embeds_many :scores, class_name:"Score"
end

class Result
  include Mongoid::Document
  # objectId 값 nil
  field :_id, type: String, default: -> {nil}
  field :type, type: String
  embedded_in :report
  embeds_many :score, class_name:"Score"
end
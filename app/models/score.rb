class Score
  include Mongoid::Document
  # objectId 값 nil
  field :_id, type: String, default: -> {nil}
  field :label, type: String
  field :value, type: Array
  embedded_in :result
end
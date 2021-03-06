# Users collection을 담당하는 User 모델 클래스
class User
  include Mongoid::Document
  # created_at / updated_at column 추가
  include Mongoid::Timestamps
  # bcrypt 적용
  include ActiveModel::SecurePassword
  # password 암호화 및 presence validation 적용
  has_secure_password
  field :email, type: String
  field :password_digest, type: String
  field :name, type: String
  field :role, type: String, default: "user"
  field :sex, type: String
  field :birthday, type: String
  field :joinType, as: :join_type, type: String
  field :fcmToken, as: :fcm_token, type: String
  field :lastSurveyed, as: :last_surveyed, type: DateTime
  field :surveyedYN, as: :surveyed_yn, type: Boolean, default: false
  # Ssum 모델을 embed함
  # embeds_many :ssums, class_name:"Ssum"
  # has_one :ssum, class_name:"Ssum"
  embeds_many :predictReports, class_name:"Report"
  # email, name, joinType이 존재해야함
  validates_presence_of :email
  validates_presence_of :name
  validates_presence_of :joinType

  # _id를 id로 수정
  def as_json(*args)
    res = super
    res["id"] = res.delete("_id").to_s
    res
  end

  # attr_accessor :email, :name, :sex, :age, :joinType, :fcmToken, :lastSurveyed, :ssums

  # initialize from both a Mongo and Web hash
  # def initialize(params={})
  #   super(params)
  #   @email=params[:email]
  #   @name=params[:name]
  #   @sex=params[:sex]
  #   @age=params[:age]
  #   @joinType=params[:joinType]
  #   @fcmToken=params[:fcmToken]
  #   @lastSurveyed=params[:lastSurveyed]
  #   @ssums=params[:ssums]
  # end
  #
  # # convenience method for access to client in console
  # def self.mongo_client
  #  Mongoid::Clients.default
  # end
  #
  # # convenience method for access to zips collection
  # def self.collection
  #  self.mongo_client['users']
  # end
  #
  # def self.find id
  #   Rails.logger.debug {"getting user #{id}"}
  #
  #   doc=collection.find(:_id=>BSON::ObjectId(id))
  #                 .projection({_id:true, email:true})
  #                 .first
  #   return doc.nil? ? User.new(doc) :doc
  # end
  #
  # def save
  #   Rails.logger.debug {"saving #{self}"}
  #
  #   self.class.collection.insert_one(
  #     email:@email,
  #     password_digest:self.password_digest,
  #     name:@name,
  #     sex:@sex,
  #     age:@age,
  #     joinType:@joinType,
  #     fcmToken:@fcmToken,
  #     # createdTime:@createdTime,
  #     # updatedTime:@updatedTime,
  #     lastSurveyed:@lastSurveyed,
  #     ssums:@ssums)
  # end
end

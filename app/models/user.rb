class User
  include Mongoid::Document
  include ActiveModel::SecurePassword
  field :email, type: String
  field :password_digest
  field :name, type: String
  field :sex, type: String
  field :age, type: String
  field :joinType, type: String
  field :fcmToken, type: String
  field :createdTime, type: Date
  field :updatedTime, type: Date
  field :updatedTime, type: Date
  field :updatedTime, type: Date
  field :lastSurveyed, type: Date
  field :ssums, type: Array
  has_secure_password

  attr_accessor :email, :name, :sex, :age, :joinType, :fcmToken, :createdTime, :updatedTime, :lastSurveyed, :ssums

  # initialize from both a Mongo and Web hash
  def initialize(params={})
    super(params)
    @email=params[:email]
    @name=params[:name]
    @sex=params[:sex]
    @age=params[:age]
    @joinType=params[:joinType]
    @fcmToken=params[:fcmToken]
    @createdTime=Time.now
    @updatedTime=Time.now
    @lastSurveyed=params[:lastSurveyed]
    @ssums=params[:ssums]
  end

  # convenience method for access to client in console
  def self.mongo_client
   Mongoid::Clients.default
  end

  # convenience method for access to zips collection
  def self.collection
   self.mongo_client['users']
  end

  def self.find id
    Rails.logger.debug {"getting user #{id}"}

    doc=collection.find(:_id=>BSON::ObjectId(id))
                  .projection({_id:true, email:true})
                  .first
    return doc.nil? ? User.new(doc) :doc
  end

  def save
    Rails.logger.debug {"saving #{self}"}

    self.class.collection.insert_one(
      email:@email,
      password_digest:self.password_digest,
      name:@name,
      sex:@sex,
      age:@age,
      joinType:@joinType,
      fcmToken:@fcmToken,
      createdTime:@createdTime,
      updatedTime:@updatedTime,
      lastSurveyed:@lastSurveyed,
      ssums:@ssums)
  end
end

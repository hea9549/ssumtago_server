class User
  include Mongoid::Document
  include ActiveModel::SecurePassword
  field :password_digest
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
    @createdTime=params[:createdTime]
    @updatedTime=params[:updatedTime]
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
    return doc.nil? ? nil : User.new(doc)
  end

  def self.find_by_email email
    Rails.logger.debug {"getting user #{email}"}

    doc=collection.find(:email=>email)
                  .projection({_id:true, email:true, password_digest:true})
                  .first
    return doc
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

class Member
  include Mongoid::Document
  include Mongoid::Timestamps

  field :trello_id
  field :username
  field :full_name
  field :avatar_id
  field :bio
  field :url

  embedded_in :effort
  
  validates_presence_of :username  

  def self.build_from(trello_member)
    trello_member.attributes.delete(:id)
    new(trello_member.attributes.merge(trello_id: trello_member.id))
  end

  def at_username
    "@#{username}"
  end

  def ==(other)
    return true if other.equal?(self)
    return false unless other.kind_of?(self.class)

    username == other.username
  end

  def eql?(other)
    return false unless other.instance_of?(self.class)
    username == other.username
  end

  def hash
    username.hash
  end

end

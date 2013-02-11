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
    trello_member_id = trello_member.id
    trello_member.attributes.delete(:id)
    new(trello_member.attributes.merge(trello_id: trello_member_id))
  end

  def at_username
    "@#{username}"
  end

  def avatar_url
    trello_member.avatar_url(size: :small)
  end

  def effort_spent
    cards = TrackedCard.where("efforts.members.username" => username)
    efforts = cards.map(&:efforts).compact.flatten

    efforts.select { |effort| effort.include?(self) }.inject(0) { |total, effort| total + effort.amount_per_member }
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

  private

  def trello_member
    @trello_member ||= Trello::Member.new("id" => trello_id, "fullName" => full_name, "username" => username,
                                           "avatarHash" => avatar_id, "bio" => bio, "url" => url)
  end

end

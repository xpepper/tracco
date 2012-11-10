class TrackedCard
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :description
  field :short_id,    type: Integer
  field :trello_id
  field :due,         type: Date
  field :closed,      type: Boolean
  field :url
  field :pos

  embeds_many :estimates
  embeds_many :efforts

  # TODO
  # belongs_to :board
  # belongs_to :list
  # has_many :members

  validates_presence_of :name, :short_id, :trello_id
  validates_numericality_of :short_id

  scope :with_trello_id, ->(a_trello_id){ where(trello_id: a_trello_id) }

  def self.build_from(trello_card)
    new(trello_card.attributes.merge(trello_id: trello_card.id))
  end

  def total_effort
    efforts.map(&:amount).inject(0, &:+)
  end

  def to_s
    "[#{name}]. Total effort: #{total_effort}h. Estimates #{estimates.map(&:to_s)}. Efforts: #{efforts.map(&:to_s)}"
  end

  def ==(other)
    return true if other.equal?(self)
    return false unless other.kind_of?(self.class)
    trello_id == other.trello_id
  end

end
class TrackedCard
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :short_id,    type: Integer
  field :name
  field :description
  field :due,         type: Date
  field :closed,      type: Boolean
  field :url
  field :pos
  
  # belongs_to :board
  # belongs_to :list
  # has_many :members
  
  def set_card(trello_card)
    @trello_card = trello_card
  end
  
  def estimates
    @estimates ||= []
  end

  def efforts
    @efforts ||= []
  end

  def total_effort
    efforts.map(&:amount).inject(0, &:+)
  end
  
  def to_s
    "[#{name}]. Total effort: #{total_effort}h. Estimates #{estimates.inspect}. Efforts: #{efforts.inspect}"
  end
  
end
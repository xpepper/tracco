FactoryGirl.define do

  factory :tracked_card, :class => Tracco::TrackedCard do
    sequence(:short_id, 1000)
    sequence(:trello_id, 100000) { |n| "xyz#{n}" }
    sequence(:name)              { |n| "any_card_#{n}" }
    description "any description"
    done   false
    closed false
  end

end

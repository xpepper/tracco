FactoryGirl.define do
  factory :tracked_card do
    sequence(:name) { |n| "any_card_#{n}" }
    description "any description"
    sequence(:short_id, 1000) { |n| n }
    sequence(:trello_id, 100000) { |n| "xyz#{n}" }
    done false
    closed false

    # embeds_many :estimates
    # embeds_many :efforts
  end
end

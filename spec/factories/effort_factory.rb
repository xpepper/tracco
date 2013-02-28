FactoryGirl.define do

  factory :effort, :class => Tracco::Effort do
    amount 4
    date Date.today
    members [Tracco::Member.new(username: "any_name")]
    sequence(:tracking_notification_id, 1000)
    muted false
  end

end

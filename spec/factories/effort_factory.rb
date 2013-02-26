FactoryGirl.define do

  factory :effort do
    amount 4
    date Date.today
    members [Member.new(username: "any_name")]
    sequence(:tracking_notification_id, 1000)
    muted false
  end

end

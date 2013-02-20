FactoryGirl.define do

  factory :estimate do
    amount 42
    date Date.today
    sequence(:tracking_notification_id, 1000)
  end

end

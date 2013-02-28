TIME_MEASUREMENTS = {
  hours:    'h',
  days:     'd',
  giorni:   'g',
  pomodori: 'p'
}

def unrecognized_notification
  create_notification(data: { 'text' => '@trackinguser hi there!' })
end

def notification_with_message(message)
  create_notification(data: { 'text' => message })
end

def create_estimate(time_measurement)
  create_notification(data: { 'text' => "@trackinguser [1.5#{TIME_MEASUREMENTS[time_measurement]}]" })
end

def create_effort(time_measurement)
  create_notification(data: { 'text' => "@trackinguser +4.5#{TIME_MEASUREMENTS[time_measurement]}]" })
end

def with(notification)
  tracking = Tracco::Tracking::Factory.build_from(notification)
  yield(tracking)
end

def with_message(notification_message, &block)
  with(notification_with_message(notification_message), &block)
end

def create_notification(custom_params)
  params = { data: { 'text' => "@trackinguser +2h" }, date: "2012-10-28T21:06:14.801Z", member_creator: stub(username: "pietrodibello") }
  params.merge!(custom_params)

  stub(data: params[:data], date: params[:date], member_creator: params[:member_creator]).as_null_object
end

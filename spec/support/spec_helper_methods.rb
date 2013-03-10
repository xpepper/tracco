TIME_MEASUREMENTS = {
  hours:    'h',
  days:     'd',
  giorni:   'g',
  pomodori: 'p'
}

def trello_testing_board_auth_params
  # auth params for trackinguser_for_test/testinguser!
  OpenStruct.new(tracker:  "trackinguser_for_test",
                 dev_key:  "ef7c400e711057d7ba5e00be20139a33",
                 token:    "9047d8fdbfdc960d41910673e300516cc8630dd4967e9b418fc27e410516362e")
end

def unrecognized_notification
  create_notification(data: { 'text' => '@any_tracker hi there!' })
end

def notification_with_message(message)
  create_notification(data: { 'text' => message })
end

def create_estimate(time_measurement)
  create_notification(data: { 'text' => "@any_tracker [1.5#{TIME_MEASUREMENTS[time_measurement]}]" })
end

def create_effort(time_measurement)
  create_notification(data: { 'text' => "@any_tracker +4.5#{TIME_MEASUREMENTS[time_measurement]}]" })
end

def with(notification)
  tracking = Tracco::Tracking::Factory.build_from(notification)
  yield(tracking)
end

def with_message(notification_message, &block)
  with(notification_with_message(notification_message), &block)
end

def create_notification(custom_params)
  params = { data: { 'text' => "@any_tracker +2h" }, date: "2012-10-28T21:06:14.801Z", member_creator: stub(username: "pietrodibello") }
  params.merge!(custom_params)

  stub(data: params[:data], date: params[:date], member_creator: params[:member_creator]).as_null_object
end

def without_logging(&block)
  original_error_level = Trello.logger.level

  begin
    Trello.logger.level = Logger::WARN
    block.call unless block.nil?
  ensure
    Trello.logger.level = original_error_level
  end
end

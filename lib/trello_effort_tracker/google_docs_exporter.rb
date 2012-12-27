require "google_drive"
require 'highline/import'

class GoogleDocsExporter

  def initialize(spreadsheet, worksheet)
    @spreadsheet = spreadsheet
    @worksheet = worksheet
  end

  def export
    columns = {
      user_story_id:        1,
      user_story_name:      2,
      start_date:           3,
      total_effort:         4,
      last_estimate_error:  5,
      estimate:             6,
    }

    spreadsheet = google_docs_session.spreadsheet_by_title(@spreadsheet)
    backlog = spreadsheet.worksheet_by_title(@worksheet)

    index = 2 # skip the header

    cards = TrackedCard.all.reject(&:no_tracking?).sort_by(&:first_activity_date).reverse
    cards.each do |card|
      print ".".color(:green)
      backlog[index, columns[:user_story_id]] = card.short_id
      backlog[index, columns[:user_story_name]] = card.name
      backlog[index, columns[:start_date]] = card.working_start_date
      backlog[index, columns[:total_effort]] = card.total_effort
      backlog[index, columns[:last_estimate_error]] = card.last_estimate_error
      card.estimates.each_with_index do |estimate, i|
        backlog[index, columns[:estimate]+i] = estimate.amount
      end
      index += 1
    end

    backlog.save
    puts "[DONE]".color(:green)
  end

  private

  def google_docs_session(email="pietro.dibello@xpeppers.com")
    @session ||= login(email)
  end

  def login(email)
    username = ask("Enter google docs username: ") { |q| q.default = email }
    password = ask("Enter google docs password: ") { |q| q.echo = false }

    GoogleDrive.login(username, password)
  end

end

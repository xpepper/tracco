require "google_drive"
require 'highline/import'

class GoogleDocsExporter

  def initialize(spreadsheet, worksheet)
    @spreadsheet = spreadsheet
    @worksheet = worksheet
  end

  def export
    columns = {
      user_story_name:  1,
      estimate:         2,
      total_effort:     3
    }

    spreadsheet = google_docs_session.spreadsheet_by_title(@spreadsheet)
    backlog = spreadsheet.worksheet_by_title(@worksheet)

    index = 2 # skip the header

    cards = TrackedCard.all.reject(&:no_tracking?).sort_by(&:first_activity_date).reverse
    cards.each do |card|
      print ".".color(:green)
      backlog[index, columns[:user_story_name]] = card.name
      backlog[index, columns[:estimate]] = card.estimates.map(&:amount).last
      backlog[index, columns[:total_effort]] = card.total_effort
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

require "google_drive"
require 'highline/import'

module Tracco
  module Exporters
    class GoogleDocs
      include TrelloConfiguration

      trap("SIGINT") { exit! }

      def initialize(spreadsheet_name, worksheet_name)
        @spreadsheet_name = spreadsheet_name || "trello effort tracking"
        @worksheet_name   = worksheet_name || "tracking"
      end

      def export
        Trello.logger.info "Running exporter from db env '#{Tracco.environment}' to google docs '#{@spreadsheet_name.color(:green)}##{@worksheet_name.color(:green)}'..."

        spreadsheet = google_docs_session.spreadsheet_by_title(@spreadsheet_name) || google_docs_session.create_spreadsheet(@spreadsheet_name)
        worksheet = spreadsheet.worksheet_by_title(@worksheet_name) || spreadsheet.add_worksheet(@worksheet_name)

        create_header(worksheet)
        index = 2 # skip the header

        cards = TrackedCard.all_tracked_cards(:method => :first_activity_date, :order => :desc)
        cards.each do |card|
          print ".".color(:green)
          worksheet[index, columns[:user_story_id]] = card.short_id
          worksheet[index, columns[:user_story_name]] = card.name
          worksheet[index, columns[:start_date]] = card.working_start_date
          worksheet[index, columns[:total_effort]] = card.total_effort
          worksheet[index, columns[:last_estimate_error]] = card.last_estimate_error
          card.estimates.each_with_index do |estimate, i|
            worksheet[index, columns[:estimate]+i] = estimate.amount
          end
          index += 1
        end

        saved = worksheet.save
        spreadsheet.human_url if saved
      end

      private

      def google_docs_session(email=configuration["google_docs_username"])
        @session ||= login(email)
      end

      def login(email)
        username = ask("Enter your google docs username: ") { |q| q.default = email }
        password = ask("Enter your google docs password: ") { |q| q.echo = false }

        GoogleDrive.login(username, password)
      end

      def columns
        @columns ||= {
          user_story_id:        1,
          user_story_name:      2,
          start_date:           3,
          total_effort:         4,
          last_estimate_error:  5,
          estimate:             6,
        }
      end

      def create_header(worksheet)
        worksheet.update_cells(1,1, [["ID", "Story Name", "Start Date", "Total Effort (hours)", "Last estimate error (%)", "First Estimate", "2nd estimate", "3rd estimate"]])
      end

    end
  end
end

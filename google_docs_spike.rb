# gem install google_drive
# gem install highline

require "google_drive"
require 'highline/import'

username = ask("Enter google docs username: ") { |q| q.default = "pietro.dibello@xpeppers.com" }
password = ask("Enter google docs password: ") { |q| q.echo = false }

session = GoogleDrive.login(username, password)

spreadsheet = session.spreadsheet_by_title("Backlog PortaleLUNA 5")
backlog = spreadsheet.worksheet_by_title("backlog")

(3..72).each do |row_index|
  puts backlog[row_index,3]
end
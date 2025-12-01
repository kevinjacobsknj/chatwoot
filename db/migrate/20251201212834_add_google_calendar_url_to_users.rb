class AddGoogleCalendarUrlToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :google_calendar_url, :string
  end
end

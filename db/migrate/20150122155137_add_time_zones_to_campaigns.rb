class AddTimeZonesToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :time_zone, :string
  end
end

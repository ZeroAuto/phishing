class RemoveTimeZonesFromCampaigns < ActiveRecord::Migration
  def change
  	remove_column :campaigns, :time_zone
  end
end

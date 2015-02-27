class AddColumnsToCampaigns < ActiveRecord::Migration
  def change
  	remove_column :campaigns, :launched
  	add_column :campaigns, :stand_down_time, :datetime
  end
end

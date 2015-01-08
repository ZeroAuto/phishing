class AddLaunchTimeToCampaign < ActiveRecord::Migration
  def change
  	add_column :campaigns, :lauch_date, :datetime
  end
end

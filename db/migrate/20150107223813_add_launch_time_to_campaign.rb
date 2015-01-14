class AddLaunchTimeToCampaign < ActiveRecord::Migration
  def change
  	add_column :campaigns, :launch_date, :datetime
  end
end

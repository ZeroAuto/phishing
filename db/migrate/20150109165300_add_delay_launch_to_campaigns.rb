class AddDelayLaunchToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :delay_launch, :boolean
  end
end

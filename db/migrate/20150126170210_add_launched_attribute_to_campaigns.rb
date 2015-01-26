class AddLaunchedAttributeToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :launched, :boolean, :default => false
  end
end

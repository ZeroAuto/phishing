class Victim < ActiveRecord::Base
	belongs_to :campaign
	has_many :visits, dependent: :destroy

	validates_format_of :email_address, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
	before_create :default_values

	attr_accessible :email_address, :uid, :campaign_id, :firstname, :lastname

	def default_values
		self.uid = (0...8).map { (65 + rand(26)).chr }.join 	
	end

  def clicked?
    # determine if victim has clicked on link or not
    self.visits.where('extra is null OR extra not LIKE ?', "%EMAIL%").empty? ? false : true
  end

  def opened?
    # determine if victim has opened on link or not
    self.visits.empty? ? false : true
  end

  def password?
    # determine if victim has enetered a password or not
    self.visits.where('extra LIKE ?', "%password%").empty? ? false : true
  end

  def self.import(file, campaign_id)
    CSV.foreach(file, headers: false) do |row|
      Victim.create!(:campaign_id => campaign_id, :email_address => row[2], :firstname => row[0], :lastname => row[1])
    end
  end

end

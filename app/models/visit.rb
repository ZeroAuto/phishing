class Visit < ActiveRecord::Base
  belongs_to :victim
  # attr_accessible :title, :body
  # attr_encrypted :extra, :key => 'a secret key'
end

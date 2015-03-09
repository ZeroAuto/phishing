# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# create global settings if it does not exist
if GlobalSettings.count == 0
	GlobalSettings.create(
		command_apache_restart: 'sudo /etc/init.d/apache2 reload',
		command_apache_status: '/etc/init.d/apache2 status'
	)
end

# create admin account with default password if it does not exist
admin = Admin.find_by(username: "admin")
unless admin.present?
	admins = Admin.create([
		{
			username: "clay",
			name: "Clayton Gouard",
			password: "0$*CqTG$4QqiJ!",
			password_confirmation: "0$*CqTG$4QqiJ!",
			email: "clayton.gouard@cynergistek.com",
			approved: true
		},
		{
			username: "dustin",
			name: "Dustin Jones",
			password: "2D*5ip4P!YYM0",
			password_confirmation: "2D*5ip4P!YYM0",
			email: "dustin.jones@cynergistek.com",
			approved: true
		},
		{
			username: "admin",
			name: "Michael Cooley",
			password: "allmyfriends",
			password_confirmation: "allmyfriends",
			email: "michael.cooley@cynergsitek.com",
			approved:true
		}
	])
end
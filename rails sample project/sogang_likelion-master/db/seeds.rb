# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# require 'csv'
#
# Team.create!({name: "그리핀도르"})
# Team.create!({name: "슬리데린"})
# Team.create!({name: "운영진"})
# User.create!({email: "master@likelion.org", password: 'likelionsg3#', name: '관리자', isMaster: true, team_id:3})
# User.create!({email: "guest@likelion.org", password: 'welcome', name: '방문자', isMaster: false, team_id:3})
#
# csv_text = File.read(Rails.root.join('lib', 'seeds', 'sogang5_member.csv'))
# csv = CSV.parse(csv_text, :headers => true, :encoding => 'UTF-8')
# csv.each do |row|
#   s = User.new
#   s.name = row['name']
#   s.email = "#{row['email']}@likelion.org"
#   s.password = row['number1'].last(8)
#   s.team_id = 1
#   s.save
#   puts "#{s.name},#{s.email},#{s.password} saved"
# end
Card.destroy_all

24.times do
  Card.create!({team:0})
end

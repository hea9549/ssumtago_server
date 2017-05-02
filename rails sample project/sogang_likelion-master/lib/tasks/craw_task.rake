require 'mechanize'

desc 'crawl unilion'
task crawl_unilion: :environment do
  # ... set options if any
  User.all.offset(1).limit(27).each do |user|
    mechanize = Mechanize.new
    page = mechanize.get('https://uni.likelion.org/')
    form = page.forms.first
    form['user[email]'] = 'rocket@likelion.org'
    form['user[password]'] = '47105607'
    page = form.submit
    link = page.link_with(text: '학생들')
    page = link.click
    form = page.forms.first
    form['search'] = "#{user.name}"
    page = form.submit
    link = page.search(".row").at("span:contains('서강대')").parent["href"]
    student =  page.link_with(:href => %r{#{link}})
    page = student.click
    values = page.search('.progress-value')
    user.lecProgress = values[0].text.strip
    user.workProgress = values[1].text.strip
    user.save
  end


end

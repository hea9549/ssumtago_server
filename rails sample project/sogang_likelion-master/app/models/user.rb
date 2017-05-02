require 'mechanize'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  belongs_to :team
  has_many :boards, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :checks, dependent: :destroy
  has_many :lectures, through: :checks
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  # def prog
  #     progress = []
  #     mechanize = Mechanize.new
  #     page = mechanize.get('https://uni.likelion.org/')
  #     form = page.forms.first
  #     form['user[email]'] = 'rocket@likelion.org'
  #     form['user[password]'] = '47105607'
  #     page = form.submit
  #     link = page.link_with(text: '학생들')
  #     page = link.click
  #     form = page.forms.first
  #     form['search'] = "#{name}"
  #     page = form.submit
  #     link = page.search(".row").at("span:contains('서강대')").parent["href"]
  #     student =  page.link_with(:href => %r{#{link}})
  #     page = student.click
  #     values = page.search('.progress-value')
  #     values.each do |number|
  #       progress << number.text.strip
  #     end
  #     progress
  # end
end

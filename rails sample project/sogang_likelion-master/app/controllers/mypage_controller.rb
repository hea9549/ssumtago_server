require 'mechanize'

class MypageController < ApplicationController
  before_action :loginCheck
  before_action :messageAll

  def index
    @likes = current_user.likes
    @projects = []
    unless current_user.comments == 0
      current_user.comments.each do |comment|
        @projects << comment.project.id
      end
    end

    # if current_user.isMaster == false
    #   mechanize = Mechanize.new
    #   page = mechanize.get('https://uni.likelion.org/')
    #   form = page.forms.first
    #   form['user[email]'] = 'rocket@likelion.org'
    #   form['user[password]'] = '47105607'
    #   page = form.submit
    #   link = page.link_with(text: '학생들')
    #   page = link.click
    #   form = page.forms.first
    #   form['search'] = "#{current_user.name}"
    #   page = form.submit
    #   link = page.link_with(dom_class: "p-2 b-gray-1 bg-white text-color-slate text-color-slate-hover bxs-gray-hover d-flex flex-column justify-content-center align-items-center")
    #   page = link.click
    #   progress = page.search('.progress-value')
    #   @lecture = progress[0].text.strip
    #   @homework = progress[1].text.strip
    # end
  end
end

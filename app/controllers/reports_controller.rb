require "bunny"
require 'json'

class ReportsController < ApplicationController
  before_action :check_jwt, only: [:input_survey]
  @@rabbitMQ_secret = ENV['RabbitMQ_pwd']

  def input_survey

    # 들어온 설문지 결과값 저장하기
    user = User.find(@user.id)
    report = Report.new
    report.survey_id = params[:surveyId]
    report.model_id = params[:modelId]
    report.version = params[:version]
    report.requestTime = DateTime.now
    report.is_processed = false
    params[:data].each do |data|
      ssumji = Ssumji.new
      ssumji.questionCode = data[:questionCode]
      ssumji.answerCode = data[:answerCode]
      report.data << ssumji
    end

    user.predictReports << report
    user.last_surveyed = DateTime.now
    user.save

    # RabbitMQ로 Q보내기
    conn = Bunny.new(:host => "expirit.co.kr", :vhost => "pushHost", :user => "ssumtago", password: @@rabbitMQ_secret)
    conn.start
    ch   = conn.create_channel
    q    = ch.queue("ssumPredict")
    requestSurvey = {userId: @user.id.to_s,
                     requestTime: report.requestTime,
                     surveyId: report.survey_id,
                     modelId: report.model_id,
                     version: report.version,
                     data: params[:data]
                    }
    ch.default_exchange.publish( requestSurvey.to_json, :routing_key => q.name )
    puts " [x] Sent #{requestSurvey.to_json}"
    conn.close
    @success = {success:"큐 전송에 성공했습니다."}
    render json: @success, status: :ok
  end

  def result
    # 들어온 설문지 결과값 저장하기
    user = User.find(params[:userId])
    report = user.predictReports.find_by(survey_id:params[:surveyId])
    report.result = params[:predictResult]
    report.is_processed = true
    report.response_time = DateTime.now
    user.predictReports << report
    user.save

    @success = {success:"예측 결과 응답을 받았습니다.", userEmail:"#{user.email}", surveyId:"#{params[:surveyId]}", predictResult:"#{params[:predictResult]}"}
    render json: @success, status: :ok
  end

end

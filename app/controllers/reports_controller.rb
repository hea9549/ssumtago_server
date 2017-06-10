# 설문지와 관련된 요청을 처리하는 컨트롤러

require "bunny"
require 'json'

class ReportsController < ApplicationController
  before_action :check_jwt, only: [:input_survey]
  @@rabbitMQ_secret = ENV['RabbitMQ_pwd']

  # [POST] /predictReports => 클라이언트로 부터 설문지 값을 받는 메서드 (check_jwt 메서드가 선행됨)
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

  # [POST] /predictResults => ML서버로 부터 예측 결과값을 받는 메서드 (check_jwt 메서드 X)
  def result
    # 들어온 설문지 결과값 저장하기
    user = User.find(params[:userId])
    report = user.predictReports.find_by(survey_id:params[:surveyId])
    report.result = params[:predictResult]
    report.is_processed = true
    report.response_time = DateTime.now
    report.save

    @success = {success:"예측 결과 응답을 받았습니다.", userEmail:"#{user.email}", surveyId:"#{params[:surveyId]}", predictResult:"#{params[:predictResult]}"}
    render json: @success, status: :ok
  end


  # [POST] /fcm => 예측 결과값을 fcm으로 보내는 메서드
  # result 메서드 뒷부분에 합칠 예정
  def fcm_push
    @headers = {
      "Content-Type" => "application/json",
      "Authorization" => "key=AAAAqms91F8:APA91bGjBdzhydJBsXyJt-1KVPVwiODVugMMlmyqcH1PrNo35HZ0XUsQujcht7_DywzWrEkIFXirXkIbtiUS8pioQwtrNxXRaX_LmcmI3IVPOhpX655J-pfR5c8CH6D68ncbteOoDwn8"
    }
    @body = {
      "data" => {
        "score" => "5x1",
        "time" => "15:10"
      },
      "to" => "bk3RNwTe3H0:CI2k_HHwgIpoDKCIZvvDMExUdFQ3P1..."
    }
    @result = HTTParty.post(
      "https://fcm.googleapis.com/fcm/send",
      headers: @headers,
      body: @body.to_json
    )

    return @result
  end

end

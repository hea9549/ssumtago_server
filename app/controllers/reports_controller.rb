require "bunny"
require 'json'

class ReportsController < ApplicationController
  before_action :check_jwt, only: [:input_survey]
  @@rabbitMQ_secret = ENV['RabbitMQ_pwd']

  def input_survey
    conn = Bunny.new(:host => "expirit.co.kr", :vhost => "pushHost", :user => "ssumtago", password: @@rabbitMQ_secret)
    conn.start
    ch   = conn.create_channel
    q    = ch.queue("ssumPredict")
    requestSurvey = {usedId: @user.id, surveyId: 1, modelId: 1, version: "1.0.1", data: [{questionCode: "01000120001", answerCode: "02001001"},
                                                                                         {questionCode: "01000120002", answerCode: "02002003"},
                                                                                         {questionCode: "01000120003", answerCode: "02003004"},
                                                                                         {questionCode: "01000120004", answerCode: "02004004"},
                                                                                         {questionCode: "01000120005", answerCode: "02005001"},
                                                                                         {questionCode: "01000112006", answerCode: "02006036"},
                                                                                         {questionCode: "01200120007", answerCode: "02007003"},
                                                                                         {questionCode: "01200120008", answerCode: "02008001"},
                                                                                         {questionCode: "01000120009", answerCode: "02009005"},
                                                                                         {questionCode: "01100120010", answerCode: "02010004"},
                                                                                         {questionCode: "01200120011", answerCode: "02011003"},
                                                                                         {questionCode: "01200000012", answerCode: "02012002"},
                                                                                         {questionCode: "01100120013", answerCode: "02013003"},
                                                                                         {questionCode: "01200120014", answerCode: "02014003"},
                                                                                         {questionCode: "01000120015", answerCode: "02015002"},
                                                                                         {questionCode: "01100120016", answerCode: "02016002"},
                                                                                         {questionCode: "01200120017", answerCode: "02017001"},
                                                                                         {questionCode: "01200111018", answerCode: "02018063"},
                                                                                         {questionCode: "01000120019", answerCode: "02019003"},
                                                                                         {questionCode: "01000120020", answerCode: "02020001"},
                                                                                         {questionCode: "01000120021", answerCode: "02021002"},
                                                                                         {questionCode: "01000120022", answerCode: "02022004"},
                                                                                         {questionCode: "01000120023", answerCode: "02023004"},
                                                                                         {questionCode: "01000120024", answerCode: "02024003"},
                                                                                         {questionCode: "01010000025", answerCode: "02025021"},
                                                                                         {questionCode: "01000120026", answerCode: "02026001"}]}
    ch.default_exchange.publish( requestSurvey.to_json, :routing_key => q.name )
    puts " [x] Sent #{requestSurvey.to_json}"
    conn.close
    @success = {success:"큐 전송에 성공했습니다."}
    render json: @success, status: :ok
  end

  def result
    @result = params[:result]
    @success = {success:"결과 응답을 받았습니다."}
    render json: @success, status: :ok
  end

end

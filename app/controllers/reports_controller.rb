# 설문지와 관련된 요청을 처리하는 컨트롤러

require "bunny"
require 'json'

class ReportsController < ApplicationController
  before_action :check_jwt, only: [:input_survey]
  @@rabbitMQ_secret = ENV['RabbitMQ_pwd']

  # [POST] /predictReports => 클라이언트로 부터 설문지 값을 받는 메서드 (check_jwt 메서드가 선행됨)
  def input_survey

    logger.info "[LINE:#{__LINE__}] 해당 user를 찾는 중..."
    # 들어온 설문지 저장하기
    begin user = User.find(@user.id)
      logger.info "[LINE:#{__LINE__}] 해당 user 찾음, 설문지 저장 중..."
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
      if user.save && params[:surveyId] && params[:modelId] && params[:version]
        logger.info "[LINE:#{__LINE__}] user에 설문지 저장완료, RabbitMQ로 전송 시작..."

        # RabbitMQ로 Q보내기
        begin
          conn = Bunny.new(:host => "expirit.co.kr", :vhost => "pushHost", :user => "ssumtago", password: @@rabbitMQ_secret)
          conn.start
          ch   = conn.create_channel
          q    = ch.queue("ssumPredict")
          requestSurvey = {userId: @user.id.to_s,
                           requestTime: report.requestTime,
                           reportId: report.id.to_s,
                           surveyId: report.survey_id,
                           modelId: report.model_id,
                           version: report.version,
                           data: params[:data]
                          }
          ch.default_exchange.publish( requestSurvey.to_json, :routing_key => q.name )
          puts " [x] Sent #{requestSurvey.to_json}"
          conn.close
          logger.info "[LINE:#{__LINE__}] RabbitMQ로 전송 완료 / 통신종료"
          @success = {success:"큐 전송에 성공했습니다."}
          render json: @success, status: :ok
        # RabbitMQ 전송 실패시
        rescue Bunny::TCPConnectionFailed
          logger.error "[LINE:#{__LINE__}] RabbitMQ 연결 끊어짐 / 통신종료"
          @error = {msg:"서버 에러로 RabbitMQ와의 연결에 실패했습니다.", code:"500", time:Time.now}
          render json: @error, status: :internal_server_error
        end

      # user에 설문지 저장 실패시
      else
        logger.error "[LINE:#{__LINE__}] 서버 에러로 설문지 저장 실패 / 통신종료"
        @error = {msg:"서버 에러로 설문지 저장에 실패했습니다. (surveyId, modelId, version 파라미터가 존재해야함)", code:"500", time:Time.now}
        render json: @error, status: :internal_server_error
      end
    # user가 없다면 에러
    rescue Mongoid::Errors::DocumentNotFound
      logger.error "[LINE:#{__LINE__}] userId에 해당하는 user가 없음 / 통신종료"
      @error = {msg: "올바른 userId 값을 넣어주세요.", code:"400", time:Time.now}
      render json: @error, status: :bad_request
    rescue Mongoid::Errors::InvalidFind
      logger.error "[LINE:#{__LINE__}] request body에 userId가 없음 / 통신종료"
      @error = {msg: "body에 userId 값을 넣어주세요.", code:"400", time:Time.now}
      render json: @error, status: :bad_request
    end
  end

  # [POST] /predictResults => ML서버로 부터 예측 결과값을 받는 메서드 (check_jwt 메서드 X)
  def result
    # 들어온 설문지 결과값 저장하기
    # userId에 해당하는 user가 있는지 확인
    puts params.inspect
    logger.info "[LINE:#{__LINE__}] userId에 해당하는 user 찾는 중..."
    begin user = User.find(params[:userId])
      logger.info "[LINE:#{__LINE__}] user 찾기 성공, user에 해당 report가 있는지 확인 중..."
      # reportId에 해당하는 predictReports가 있는지 확인
      begin report = user.predictReports.find(params[:reportId])
        logger.info "[LINE:#{__LINE__}] report 찾기 성공, 해당 report에 결과 값 저장 중..."
        report.result = params[:predictResult]
        report.is_processed = true
        report.response_time = DateTime.now
        report.save

        @success = {success:"예측 결과 응답을 받았습니다.", userEmail:"#{user.email}", predictResult:"#{params[:predictResult]}"}
        render json: @success, status: :ok
      # predictReports가 없다면 에러
      rescue Mongoid::Errors::DocumentNotFound
        logger.error "[LINE:#{__LINE__}] reportId에 해당하는 report가 없음 / 통신종료"
        @error = {msg: "올바른 reportId 값을 넣어주세요.", code:"400", time:Time.now}
        render json: @error, status: :bad_request
      rescue Mongoid::Errors::InvalidFind
        logger.error "[LINE:#{__LINE__}] body에 reportId가 없음 / 통신종료"
        @error = {msg: "body에 reportId 값을 넣어주세요.", code:"400", time:Time.now}
        render json: @error, status: :bad_request
      end
    # user가 없다면 에러
    rescue Mongoid::Errors::DocumentNotFound
      logger.error "[LINE:#{__LINE__}] userId에 해당하는 user가 없음 / 통신종료"
      @error = {msg: "올바른 userId 값을 넣어주세요.", code:"400", time:Time.now}
      render json: @error, status: :bad_request
    rescue Mongoid::Errors::InvalidFind
      logger.error "[LINE:#{__LINE__}] body에 userId가 없음 / 통신종료"
      @error = {msg: "body에 userId 값을 넣어주세요.", code:"400", time:Time.now}
      render json: @error, status: :bad_request
    end
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

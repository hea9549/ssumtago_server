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
        if report.save
          logger.info "[LINE:#{__LINE__}] report에 결과 값 저장 성공, fcm 전송 시작..."
          # report 결과 저장 성공시
          # fcm 시작
          @headers = {
            "Content-Type" => "application/json",
            "Authorization" => "key=AAAAXq8WLYs:APA91bEuNpbkWAL5mu2XCIdNsV8DoLOd9BNBgbB9WgBFjT1GdgcUhcdEijpsc5soDGj2T9M9YQXO_NAVk2YGFVBpZNBzdViTCwfWf0uV2hHfn7P5Q-PbXxsn1LipS-ZZBCexdJiwcTbe "
          }
          @body = {
            "data" => {
              # 03yyyy, 푸쉬의 종류
              # 030001은 썸지 결과 푸쉬
              "pushType" => "030001",
              "data" => {
                "_id" => report.id.to_s,
                "surveyId" => report.survey_id,
                "modelId" => report.model_id,
                "version" => report.version,
                "requestTime" => report.request_time,
                "responseTime" => report.response_time,
                "isProcessed" => report.is_processed,
                "data" => report.data.map{|x|x.attributes},
                "result" => report.result
              }
            },
            "to" => "f3iDP3aghcc:APA91bE_n3b2IepFR5ZKk1th6VHNycG9uvqafbhVCWU88fPKj4U_Na-7hfymKGAYsKwG-Q9EzvHUYiT2HMRqZIGvXMGKyQnhQ_GBbAljO5q8hS9dkXBs6tSmZgnL6mmV5EBDvEqTNp5b"
          }
          # puts @body.to_json
          @result = HTTParty.post(
            "https://fcm.googleapis.com/fcm/send",
            headers: @headers,
            body: @body.to_json
          )
          case @result.code.to_i
            when 200
              logger.info "[LINE:#{__LINE__}] fcm 전송 성공 / 통신종료 "
              @success = {success:"예측 결과 응답 저장 후 성공적으로 fcm으로 보냈습니다."}
              render json: @msg, status: :ok
            when 401...600
              logger.error "[LINE:#{__LINE__}] 통신 에러로 fcm 전송 실패 / 통신종료 "
              @error = {msg:"예측 결과 응답 저장은 성공했지만, 서버 에러로 fcm전송에 실패했습니다.", code:"500", time:Time.now}
              render json: @error, status: :internal_server_error
          end
        else
          logger.error "[LINE:#{__LINE__}] report에 결과 값 저장 실패 / 통신종료 "
          @error = {msg:"서버 에러로 report 결과 저장에 실패했습니다.", code:"500", time:Time.now}
          render json: @error, status: :internal_server_error
        end

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
      "Authorization" => "key=AAAAXq8WLYs:APA91bEuNpbkWAL5mu2XCIdNsV8DoLOd9BNBgbB9WgBFjT1GdgcUhcdEijpsc5soDGj2T9M9YQXO_NAVk2YGFVBpZNBzdViTCwfWf0uV2hHfn7P5Q-PbXxsn1LipS-ZZBCexdJiwcTbe "
    }
    @body = {
      "data" => {
        "pushType" => "030001",
        "data" => {
          "_id" => "1",
          "surveyId" => "1",
          "modelId" => "1",
          "version" => "1",
          "requestTime" => "1",
          "responseTime" => "1",
          "isProcessed" => "!",
          "data" => ["questionCode"=>"01000120001", "answerCode" => "02001001"],
          "result" => ["1"]
        }
      },
      "to" => "f3iDP3aghcc:APA91bE_n3b2IepFR5ZKk1th6VHNycG9uvqafbhVCWU88fPKj4U_Na-7hfymKGAYsKwG-Q9EzvHUYiT2HMRqZIGvXMGKyQnhQ_GBbAljO5q8hS9dkXBs6tSmZgnL6mmV5EBDvEqTNp5b"
    }
    puts @body.to_json
    @result = HTTParty.post(
      "https://fcm.googleapis.com/fcm/send",
      headers: @headers,
      body: @body.to_json
    )

    puts @result.response.message
    case @result.code
      when 200
        @success = {success:"예측 결과 응답 저장 후 성공적으로 fcm으로 보냈습니다."}
        render json: @msg, status: :ok
      when 401...600
        @error = {msg:"예측 결과 응답 저장은 성공했지만, 서버 에러로 fcm전송에 실패했습니다.", code:"500", time:Time.now}
        render json: @error, status: :internal_server_error
    end
  end

end

# 설문지와 관련된 요청을 처리하는 컨트롤러

require "bunny"
require 'json'

class ReportsController < ApplicationController
  before_action :check_jwt, only: [:read_sruvey, :create_survey, :update_survey, :delete_survey]
  @@rabbitMQ_secret = ENV['RabbitMQ_pwd']
  @@fcm_auth = ENV['FCM_AUTHORIZATION']
  @@haesung_phone_token = ENV['HS_TOKEN']

  # [GET] /predictReports => 설문지를 불러오는 메서드 (check_jwt 메서드가 선행됨)
  def read_sruvey
    logger.info "[LINE:#{__LINE__}] 해당 user 찾음, 불러올 설문지 찾는 중..."
    # begin @report = @user.ssums.find_by(id:params[:ssumId]).predictReports.find_by(_id:params[:reportId])
    # begin @report = @user.ssum.predictReports.find_by(_id:params[:reportId])
    begin @report = @user.predictReports.find_by(_id:params[:reportId])
        logger.info "[LINE:#{__LINE__}] 설문지 확인, 설문지 데이터 응답 완료 / 통신종료"

      # @success = {success:"설문지 응답 완료", report: @report}
      render json: @report, status: :ok


    # 설문지를 찾을 수 없을 때
    rescue Mongoid::Errors::DocumentNotFound
      logger.error "[LINE:#{__LINE__}] user에 해당 reportId의 설문지를 찾을 수 없음 / 통신종료"
      @error = {msg:"user에 해당 reportId의 설문지를 찾을 수 없습니다.", code:"500", time:Time.now}
      render json: @error, status: :internal_server_error
    end
  end


  # [POST] /predictReports => 클라이언트로 부터 설문지 값을 받는 메서드 (check_jwt 메서드가 선행됨)
  def create_survey

    # logger.info "[LINE:#{__LINE__}] 해당 user를 찾는 중..."
    # begin user = User.find(@user.id)
      logger.info "[LINE:#{__LINE__}] 해당 user 찾음, 설문지 저장 중..."
      report = Report.new
      report.survey_id = params[:surveyId]
      # report.model_id = params[:modelId]
      report.version = params[:version]
      report.requestTime = DateTime.now
      report.is_processed = false
      params[:data].each do |data|
        ssumji = Ssumji.new
        ssumji.questionCode = data[:questionCode]
        ssumji.answerCode = data[:answerCode]
        report.data << ssumji
      end

      # user의 해당 ssum에 설문을 저장
      # ssums가 배열에서 단일 객체로 변경
      # ssums = @user.ssums.find_by(id: params[:ssumId])
      # ssums = @user.ssum
      # ssums.predictReports << report
      @user.predictReports << report
      @user.last_surveyed = DateTime.now
      # if @user.save && params[:surveyId] && params[:modelId] && params[:version]
      if @user.save && params[:surveyId] && params[:version]
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
                          #  modelId: report.model_id,
                           version: report.version,
                           data: params[:data]
                          }
          ch.default_exchange.publish( requestSurvey.to_json, :routing_key => q.name )
          puts " [x] Sent #{requestSurvey.to_json}"
          conn.close
          logger.info "[LINE:#{__LINE__}] RabbitMQ로 전송 완료 / 통신종료"
          # @success = {success:"설문지 저장 완료, 큐 전송에 성공했습니다."}
          render json: report, status: :created
        # RabbitMQ 전송 실패시
        rescue Bunny::TCPConnectionFailed
          logger.error "[LINE:#{__LINE__}] RabbitMQ 연결 끊어짐 / 통신종료"
          @error = {msg:"서버 에러로 RabbitMQ와의 연결에 실패했습니다.", code:"500", time:Time.now}
          render json: @error, status: :internal_server_error
        end

      # user에 설문지 저장 실패시
      else
        logger.error "[LINE:#{__LINE__}] 서버 에러로 설문지 저장 실패 / 통신종료"
        # @error = {msg:"서버 에러로 설문지 저장에 실패했습니다. (surveyId, modelId, version 파라미터가 존재해야함)", code:"500", time:Time.now}
        @error = {msg:"서버 에러로 설문지 저장에 실패했습니다. (surveyId, version 파라미터가 존재해야함)", code:"500", time:Time.now}
        render json: @error, status: :internal_server_error
      end
    # user가 없다면 에러 (jwt 에서 유저를 반환하기 때문에 체크할 필요 없음)
    # rescue Mongoid::Errors::DocumentNotFound
    #   logger.error "[LINE:#{__LINE__}] userId에 해당하는 user가 없음 / 통신종료"
    #   @error = {msg: "올바른 userId 값을 넣어주세요.", code:"400", time:Time.now}
    #   render json: @error, status: :bad_request
    # rescue Mongoid::Errors::InvalidFind
    #   logger.error "[LINE:#{__LINE__}] request body에 userId가 없음 / 통신종료"
    #   @error = {msg: "body에 userId 값을 넣어주세요.", code:"400", time:Time.now}
    #   render json: @error, status: :bad_request
    # end
  end

  # [PATCH] /predictReports => 설문지 내용 수정하는 메서드 (check_jwt 메서드가 선행됨)
  def update_survey
    logger.info "[LINE:#{__LINE__}] 해당 user 찾음, 업데이트할 설문지 찾는 중..."
    # begin @report = @user.ssums.find_by(id:params[:ssumId]).predictReports.find_by(_id:params[:reportId])
    # begin @report = @user.ssum.predictReports.find_by(_id:params[:reportId])
    begin @report = @user.predictReports.find_by(_id:params[:reportId])
      logger.info "[LINE:#{__LINE__}] 설문지 확인, 설문지 업데이트 중..."
      @report.requestTime = DateTime.now
      @report.is_processed = false
      # 이전 설문 내용들을 지우고 다시 추가하기
      @report.data.destroy
      params[:data].each do |data|
        ssumji = Ssumji.new
        ssumji.questionCode = data[:questionCode]
        ssumji.answerCode = data[:answerCode]
        @report.data << ssumji
      end

      @report.save
      @user.last_surveyed = DateTime.now
      # if @user.save && params[:surveyId] && params[:modelId] && params[:version]
      # update에도 id 들이 필요한가?
      if @user.save
        logger.info "[LINE:#{__LINE__}] user에 설문지 업데이트 완료, RabbitMQ로 전송 시작..."

        # RabbitMQ로 Q보내기
        begin
          conn = Bunny.new(:host => "expirit.co.kr", :vhost => "pushHost", :user => "ssumtago", password: @@rabbitMQ_secret)
          conn.start
          ch   = conn.create_channel
          q    = ch.queue("ssumPredict")
          requestSurvey = {userId: @user.id.to_s,
                           requestTime: @report.requestTime,
                           reportId: @report.id.to_s,
                           surveyId: @report.survey_id,
                          #  modelId: @report.model_id,
                           version: @report.version,
                           data: params[:data]
                          }
          ch.default_exchange.publish( requestSurvey.to_json, :routing_key => q.name )
          puts " [x] Sent #{requestSurvey.to_json}"
          conn.close
          logger.info "[LINE:#{__LINE__}] RabbitMQ로 전송 완료 / 통신종료"
          # @success = {success:"설문지 업데이트 완료, 큐 전송에 성공했습니다."}
          render json: @report, status: :ok
        # RabbitMQ 전송 실패시
        rescue Bunny::TCPConnectionFailed
          logger.error "[LINE:#{__LINE__}] RabbitMQ 연결 끊어짐 / 통신종료"
          @error = {msg:"서버 에러로 RabbitMQ와의 연결에 실패했습니다.", code:"500", time:Time.now}
          render json: @error, status: :internal_server_error
        end

      # user에 설문지 저장 실패시
      else
        logger.error "[LINE:#{__LINE__}] 서버 에러로 설문지 업데이트 실패 / 통신종료"
        # @error = {msg:"서버 에러로 설문지 저장에 실패했습니다. (surveyId, modelId, version 파라미터가 존재해야함)", code:"500", time:Time.now}
        @error = {msg:"서버 에러로 설문지 저장에 실패했습니다.", code:"500", time:Time.now}
        render json: @error, status: :internal_server_error
      end

    # 설문지를 찾을 수 없을 때
    rescue Mongoid::Errors::DocumentNotFound
      logger.error "[LINE:#{__LINE__}] user에 해당 reportId의 설문지를 찾을 수 없음 / 통신종료"
      @error = {msg:"user에 해당 reportId의 설문지를 찾을 수 없습니다.", code:"500", time:Time.now}
      render json: @error, status: :internal_server_error
    end
  end

  # [DELETE] /predictReports => 설문지를 삭제하는 메서드 (check_jwt 메서드가 선행됨)
  def delete_survey
    logger.info "[LINE:#{__LINE__}] 해당 user 찾음, 삭제할 설문지 찾는 중..."
    # begin @report = @user.ssums.find_by(id:params[:ssumId]).predictReports.find_by(_id:params[:reportId])
    # begin @report = @user.ssum.predictReports.find_by(_id:params[:reportId])
    begin @report = @user.predictReports.find_by(_id:params[:reportId])
      logger.info "[LINE:#{__LINE__}] 설문지 확인, 설문지 삭제 완료 / 통신종료"
      @report.destroy

      @success = {success:"설문지 삭제 완료"}
      render json: @success, status: :ok

    # 설문지를 찾을 수 없을 때
    rescue Mongoid::Errors::DocumentNotFound
      logger.error "[LINE:#{__LINE__}] user에 해당 reportId의 설문지를 찾을 수 없음 / 통신종료"
      @error = {msg:"user에 해당 reportId의 설문지를 찾을 수 없습니다.", code:"500", time:Time.now}
      render json: @error, status: :internal_server_error
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
      # begin report = user.ssums.find_by(id:params[:ssumId]).predictReports.find(params[:reportId])
      begin report = user.predictReports.find(params[:reportId])
        logger.info "[LINE:#{__LINE__}] report 찾기 성공, 해당 report에 결과 값 저장 중..."
        report.result = params[:predictResults]
        report.is_processed = true
        report.response_time = DateTime.now
        if report.save
          logger.info "[LINE:#{__LINE__}] report에 결과 값 저장 성공, fcm 전송 시작..."
          # report 결과 저장 성공시
          # fcm 시작
          @headers = {
            "Content-Type" => "application/json",
            "Authorization" => @@fcm_auth
          }
          if params[:deviceType] == "android"
            @body = {
              "data" => {
                # 03yyyy, 푸쉬의 종류
                # 030001은 썸지 결과 푸쉬
                "pushType" => "030001",
                "data" => {
                  "_id" => report.id.to_s,
                  "surveyId" => report.survey_id,
                  # "modelId" => report.model_id,
                  "version" => report.version,
                  "requestTime" => report.request_time,
                  "responseTime" => report.response_time,
                  "isProcessed" => report.is_processed,
                  "data" => report.data.map{|x|x.attributes},
                  "result" => report.result
                }
              },
              # "to" => @@haesung_phone_token
              "to" => user.fcmToken
            }
          elsif params[:deviceType] == "ios"
            @body = {
              "aps": {
                "alert" => "결과가 도착했습니다!",
                "type" => "result",
                "data" => {
                  "pushType" => "030001",
                  "notification" => {
                    "_id" => report.id.to_s,
                    "result" => report.result
                  }
                }
              }
            }
          end
          puts @body.to_json
          @result = HTTParty.post(
            "https://fcm.googleapis.com/fcm/send",
            headers: @headers,
            body: @body.to_json
          )
          case @result.code.to_i
            when 200
              logger.info "[LINE:#{__LINE__}] fcm 전송 성공 / 통신종료 "
              # @success = {success:"예측 결과 응답 저장 후 성공적으로 fcm으로 보냈습니다."}
              render json: report, status: :ok
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
          # "modelId" => "1",
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

  private
    # Reports 컨트롤러 공용메서드를 적는 부분

    # def set_ssums
    #   @ssum = User.find(params[:ssumId])
    # end

    # 명시된 key값으로 날라오는 parameter들만 받는 메서드 (white list)
    def report_params
      # params.permit(:email, :password, :joinType, :name, :sex, :age, :fcmToken, :createdTime, :updatedTime, :lastSurveyed, :ssums)
    end

end

class NoticesController < ApplicationController
  before_action :check_jwt, only: [:notify_one]
  @@rabbitMQ_secret = ENV['RabbitMQ_pwd']
  @@fcm_auth = ENV['FCM_AUTHORIZATION']
  @@haesung_phone_token = ENV['HS_TOKEN']
  @@RabbitMQ_Queue = ENV['RabbitMQ_Queue']


  # [POST] /notifications/ => 공지사항 보내기
  def notify_one
    logger.info "[LINE:#{__LINE__}] 해당 user 찾음,  user가 admin 인지 확인 중..."
    # 해당 user가 admin인지 확인 중...
    if @user.role == "admin"
      logger.info "[LINE:#{__LINE__}] admin User 확인, 개인 알림 / 전체 메세지 구분을 위해 파라미터에 userId가 있는지 확인 중..."
      # 전체 notification인지 아닌지 확인
      if params[:userId].present?
        # 개인메세지
        logger.info "[LINE:#{__LINE__}] 파라미터에 userId 확인 => 개인메세지"
        # userId에 해당하는 user가 있는지 확인
        puts params.inspect
        logger.info "[LINE:#{__LINE__}] userId에 해당하는 user 찾는 중..."
        begin receiver = User.find(params[:userId])
            logger.info "[LINE:#{__LINE__}] fcm 보내는 중..."
            @headers = {
              "Content-Type" => "application/json",
              "Authorization" => @@fcm_auth
            }
            @body = {
              "priority" => "high",
              "data" => {
                "code":"100",
                "body":{
                  "title" => params[:title],
                  "message" => params[:message],
                  "url" => params[:url]
                },
                "header": params[:header]
              },
              "to" => receiver.fcmToken
            }
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
                @error = {msg:"서버 에러로 fcm전송에 실패했습니다.", code:"500", time:Time.now}
                render json: @error, status: :internal_server_error
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
      else
        # 전체메세지
        logger.info "[LINE:#{__LINE__}] 파라미터에 userId 없음 => 전체메세지"
        @error = {msg: "아직 전체 메세지 개발이 안됐어용", code:"400", time:Time.now}
        render json: @error, status: :bad_request
        
      end
    else
      logger.error "[LINE:#{__LINE__}] admin user가 아님 / 통신종료"
      @error = {msg: "admin이 아닙니다.", code:"401", time:Time.now}
      render json: @error, status: :unauthorized
    end
  end
end

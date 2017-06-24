# 모든 컨트롤러 공용 메서드를 담는 컨트롤러

class ApplicationController < ActionController::API
  @@hmac_secret = ENV['HAMC_SECRET']

  private
    # JWT 값을 확인하는 메서드
    # 확인될시 User 객체 반환
    def check_jwt

      logger.info "[LINE:#{__LINE__}] 리퀘스트 헤더에 jwt가 있는지 확인중..."
      if request.headers["jwt"]
        logger.info "[LINE:#{__LINE__}] 헤더에 jwt 여부 확인완료"
        @jwt = request.headers["jwt"]
        logger.info "[LINE:#{__LINE__}] jwt 디코딩 중..."
        begin @decoded_token = JWT.decode @jwt, @@hmac_secret, true, { :algorithm => 'HS256' }
         logger.info "[LINE:#{__LINE__}] jwt 디코딩 성공"
         # JWT를 decode 하면 배열이 나온는데 첫 번째 값에 유저 정보가 들어있음
         @info = @decoded_token[0]
          logger.info "[LINE:#{__LINE__}] jwt 만료시간 확인 중..."
          # 만료시간 체크
          if Time.now <= Time.parse(@info["expireTime"])
            logger.info "[LINE:#{__LINE__}] jwt 인증 성공, user 찾는 중.."
            begin @user = User.find_by(email: @info["email"])
            rescue Mongoid::Errors::DocumentNotFound
              logger.error "[LINE:#{__LINE__}] 유저를 찾을 수 없음 / 통신 종료"
              @error = {msg: "유저를 찾을 수 없습니다.", code:"400", time:Time.now}
              render json: @error, status: :bad_request and return
            end
          else
            logger.error "[LINE:#{__LINE__}] jwt 만료 / 통신 종료"
            @error = {msg: "Token이 만기됐습니다!", code:"401", time: Time.now}
            render json: @error, status: :unauthorized
          end
        # JWT decode 실패시
        rescue JWT::IncorrectAlgorithm
          logger.error "[LINE:#{__LINE__}] 잘못된 jwt 값 / 통신 종료"
          @error = {msg: "올바른 Token 값을 넣어주세요!", code:"401", time:Time.now}
          render json: @error, status: :unauthorized
        rescue JWT::VerificationError
          logger.error "[LINE:#{__LINE__}] 잘못된 jwt 값 / 통신 종료"
          @error = {msg: "올바른 Token 값을 넣어주세요!", code:"401", time:Time.now}
          render json: @error, status: :unauthorized
        rescue JWT::DecodeError
          logger.error "[LINE:#{__LINE__}] 잘못된 jwt 값 / 통신 종료"
          @error = {msg: "올바른 Token 값을 넣어주세요!", code:"401", time:Time.now}
          render json: @error, status: :unauthorized
        end
      # request Header에 jwt가 없을시
      else
        logger.error "[LINE:#{__LINE__}] 헤더에 jwt가 없음 / 통신 종료"
        @error = {msg: "Header에 Token 값을 넣어주세요!", code:"400", time:Time.now}
        render json: @error, status: :bad_request
      end
    end
end

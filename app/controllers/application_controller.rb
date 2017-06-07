class ApplicationController < ActionController::API
  @@hmac_secret = ENV['HAMC_SECRET']

  private
    def check_jwt
      if request.headers["jwt"]
        @jwt = request.headers["jwt"]
        begin @decoded_token = JWT.decode @jwt, @@hmac_secret, true, { :algorithm => 'HS256' }
         @info = @decoded_token[0]
          if Time.now <= Time.parse(@info["expireTime"])
            @user = User.find_by(email: @info["email"])
            # @info = {
            #   email: @user["email"],
            #   name: @user["name"],
            #   sex: @user["sex"],
            #   ssums: @user["ssums"]
            # }
          else
            @error = {msg: "Token이 만기됐습니다!", code:"401", time: Time.now}
            render json: @error, status: :unauthorized
          end
        rescue JWT::IncorrectAlgorithm
          @error = {msg: "올바른 Token 값을 넣어주세요!", code:"401", time:Time.now}
          render json: @error, status: :unauthorized
        rescue JWT::VerificationError
          @error = {msg: "올바른 Token 값을 넣어주세요!", code:"401", time:Time.now}
          render json: @error, status: :unauthorized
        rescue JWT::DecodeError
          @error = {msg: "올바른 Token 값을 넣어주세요!", code:"401", time:Time.now}
          render json: @error, status: :unauthorized
        end
      else
        @error = {msg: "Header에 Token 값을 넣어주세요!", code:"400", time:Time.now}
        render json: @error, status: :bad_request
      end
    end
end

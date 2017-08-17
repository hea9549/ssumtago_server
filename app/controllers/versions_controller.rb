class VersionsController < ApplicationController
  def versionsCheck
    logger.info "[LINE:#{__LINE__}] version 리턴완료 / 통신종료"
    @versions = {
      androidVersion:"1.0.0",
      iosVersion:"1.0.3",
      dbVersion:"1.0.0"
    }
    render json: @versions, status: :ok
  end
end

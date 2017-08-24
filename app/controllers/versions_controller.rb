class VersionsController < ApplicationController
  def versionsCheck
    logger.info "[LINE:#{__LINE__}] version 리턴완료 / 통신종료"
    @versions = {
      androidVersion: Rails.configuration.x.android_app_version,
      iosVersion: Rails.configuration.x.ios_app_version,
      serverVersion: Rails.configuration.x.server_app_version,
      dbVersion: Rails.configuration.x.db_version
    }
    render json: @versions, status: :ok
  end
end

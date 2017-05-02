module ApplicationCable
  class Connection < ActionCable::Connection::Base
  end
end

# module ApplicationCable
#   class Connection < ActionCable::Connection::Base
#     identified_by :current_user
#
#     def connect
#       self.current_user = find_verified_user
#       logger.add_tags current_user.name
#     end
#
#     def disconnect
#       # Any cleanup work needed when the cable connection is cut.
#     end
#
#     protected
#       def find_verified_user
#         if current_user = User.find_by_identity cookies.signed[:identity_id]
#           current_user
#         else
#           reject_unauthorized_connection
#         end
#       end
#   end
# end

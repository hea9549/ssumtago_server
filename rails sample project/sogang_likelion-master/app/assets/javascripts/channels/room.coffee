App.room = App.cable.subscriptions.create "RoomChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    alert("서버와 연결이 끊겼습니다! 새로고침을 해주세요!")
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # alert data['message']
    $('#messages').append data['message']
    # $('#messages').append data['user_id']
    $(".scrollbar").animate({ scrollTop: $(".force-overflow").height() }, "slow");
    # Called when there's incoming data on the websocket for this channel

  speak: (message)->
    @perform 'speak', message: message
    # @perform 'speak', user_id: message[1]
    # @perform 'id', message: message

$(document).on 'keypress', '[data-behavior~=room_speaker]', (event) ->
  if event.keyCode is 13 # return = send
    # values = [$('#user_id').val(), event.target.value]
    # App.room.speak values[0]
    # App.room.speak values
    App.room.speak event.target.value
    event.target.value = ''
    event.preventDefault()

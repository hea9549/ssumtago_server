require 'mailgun'

class MailerController < ApplicationController
  def index


  end

  def sender
    # First, instantiate the Mailgun Client with your API key
    mg_client = Mailgun::Client.new 'key-7f5142c419428fa7d4f80b1346f0efc4'

    # Define your message parameters
    message_params =  { from: 'sogang@likelion.org',
                        to:   'sogang@likelion.org',
                        subject: 'The Ruby SDK is awesome!',
                        text:    'It is really easy to send a message!'
                      }

    # Send your message through the client
    mg_client.send_message 'sandbox8d4b4b0f4a314363a76f174f31aa70de.mailgun.org', message_params
  end
end

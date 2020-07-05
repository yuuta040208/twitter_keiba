require 'rest-client'

module LineApi
  module Client
    BROADCAST_URL = 'https://api.line.me/v2/bot/message/broadcast'

    def self.broadcast_messages(template)
      payload = {
          Authorization: ENV.fetch('LINE_CHANNEL_ACCESS_TOKEN'),
          content_type: :json,
          accept: :json
      }

      RestClient.post(BROADCAST_URL, {messages: [template.to_hash]}.to_json, payload)
    end
  end
end

module TresDelta
  class Response
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def success?
      @response[:succeeded]
    end

    def self.create_from_action(action, response)
      self.new(response.body["#{action}_response".to_sym]["#{action}_result".to_sym])
    end
  end
end

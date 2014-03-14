require "tres_delta/version"
require "tres_delta/client"
require "tres_delta/config"
require "tres_delta/credit_card"
require "tres_delta/credit_card/address"
require "tres_delta/customer"
require "tres_delta/gateway"
require "tres_delta/response"
require "tres_delta/vault"

module TresDelta
  class Errors
    CARD_NUMBER_IN_USE = "CardNumberInUse"
    VALIDATION_FAILED = "ValidationFailed"
  end
end

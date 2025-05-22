# frozen_string_literal: true

require 'http'

module LostNFound
  ## Send email verification email
  # params:
  #   - registration: hash with keys :username :email :verification_url :exp
  class VerifyRegistration
    # Error for invalid registration details
    class InvalidRegistration < StandardError; end
    class EmailProviderError < StandardError; end

    def initialize(registration)
      @registration = registration
    end

    def from_email = ENV.fetch('MAILJET_FROM_EMAIL')
    def mail_api_key = ENV.fetch('MAILJET_API_KEY')
    def mail_api_secret = ENV.fetch('MAILJET_API_SECRET')
    def mail_url = ENV.fetch('MAILJET_API_URL')

    def call
      raise(InvalidRegistration, 'Username exists') unless username_available?
      raise(InvalidRegistration, 'Email already used') unless email_available?

      send_email_verification
    end

    def username_available?
      Account.first(username: @registration[:username]).nil?
    end

    def email_available?
      Account.first(email: @registration[:email]).nil?
    end

    def html_email
      <<~END_EMAIL
        <H1>LostNFound Platform Registration</H1>
        <p>Please <a href="#{@registration[:verification_url]}">click here</a>
        to validate your email.
        You will be asked to set a password to activate your account.</p>
      END_EMAIL
    end

    def mail_json # rubocop:disable Metrics/MethodLength
      {
        Messages: [
          {
            From: {
              Email: from_email,
              Name: 'LostNFound Platform'
            },
            To: [{
              Email: @registration[:email],
              Name: @registration[:username]
            }],
            Subject: 'LostNFound Platform Registration Verification',
            HTMLPart: html_email
          }
        ]
      }
    end

    def send_email_verification # rubocop:disable Metrics/AbcSize
      res = HTTP.basic_auth(user: mail_api_key, pass: mail_api_secret)
                .post(mail_url, json: mail_json)
      raise(EmailProviderError, "#{res.status} #{res.body}") if res.status >= 300
    rescue EmailProviderError => e
      Api.logger.error "Email provider error: #{e.inspect}"
      raise EmailProviderError
    rescue StandardError => e
      Api.logger.error "Verify registration error: #{e.inspect}, trace: #{e.backtrace}"
      raise(InvalidRegistration,
            'Could not send verification email; please check email address')
    end
  end
end

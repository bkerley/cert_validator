require 'uri'
require 'base64'
require 'net/http'
require 'cert_validator/ocsp/extractor'

class CertValidator
  class RealOcspValidator
    attr_reader :certificate
    attr_reader :ca
    attr_accessor :logger

    include OcspFailures

    def initialize(cert, ca)
      @certificate = cert
      @ca = ca

      @extractor = Extractor.new @certificate
    end

    def available?
      @extractor.has_ocsp_extension?
    end

    def valid?
      return false unless available?

      begin
        validate!
      rescue => e
        log e
        return false
      end
      
      return true
    end

    def validate!
      raise FetchError.new unless http_body = fetch(request_uri)
      
      body = OpenSSL::OCSP::Response.new http_body

      check_ocsp_response body
      check_ocsp_payload body.basic.status.first
    end

    private
    def log(msg)
      return unless logger

      logger.info msg
    end

    def check_ocsp_response(body)
      raise NonzeroStatus.new(body.status) unless body.status == 0
      raise ResponseMismatch.new unless body.basic.verify *verify_args
      raise MissingStatus.new unless body.basic.status.first

      # http://rdoc.info/stdlib/openssl/OpenSSL/OCSP/Request:check_nonce
      # greater than zero is acceptable
      nonce_result = req.check_nonce body.basic
      raise UnacceptableNonce.new(nonce_result) unless nonce_result > 0

      return true
    end

    def check_ocsp_payload(status)
      unless status[0].serial == certificate.serial
        raise SerialMisatch(got, expected) 
      end

      validity_range = (status[4]..status[5])
      unless validity_range.cover? Time.now
        raise NotValidNow.new(validity_range)
      end

      raise Revoked if status[1] == 1
      raise UnexpectedStatus(status[1]) if status[1] != 0
      
      return true
    end

    def verify_args
      store = OpenSSL::X509::Store.new
      store.add_cert ca

      [[ca], store]
    end

    def req
      return @req if defined? @req

      @req = OpenSSL::OCSP::Request.new
      @req.add_nonce
      @req.add_certid cert_id

      return @req
    end

    def request_uri
      return @request_uri if defined? @request_uri
      pem = Base64.encode64(req.to_der).strip
      return @request_uri = URI(@extractor.endpoint + '/' + URI.encode_www_form_component(pem))
    end

    def fetch(uri)
      resp = Net::HTTP.get_response URI(uri)
      return resp.body if resp.code == '200'

      return nil
    end

    def cert_id
      @cert_id ||= OpenSSL::OCSP::CertificateId.new certificate, ca
    end
  end
end

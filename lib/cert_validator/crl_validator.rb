require 'cert_validator/crl/extractor'
class CertValidator
  class CrlValidator
    attr_reader :certificate
    attr_writer :crl

    attr_reader :revoked_time

    def initialize(cert)
      @certificate = cert
    end

    def available?
      return true if has_crl_data?
      return false unless extractor.has_distribution_points?
    end

    def valid?
      return false unless available?
      
      return false if revoked?

      return true
    end

    def crl
      return @crl if defined? @crl
      
      distribution_points = extractor.distribution_points
      distribution_points.first do |dp|
        @crl = fetch dp
      end
    end

    private
    def has_crl_data?
      !! crl
    end

    def extractor
      @extractor ||= Extractor.new certificate
    end

    def fetch(uri)
      resp = Net::HTTP.get_response URI(uri)
      return resp.body if resp.code == 200

      return nil
    end

    def vivified_crl
      @vivified_crl ||= OpenSSL::X509::CRL.new crl
    end

    def revoked?
      vivified_crl.revoked.find do |entry|
        entry.serial == certificate.serial
      end.tap do |entry|
        next if entry.nil?
        @revoked_time = entry.time
      end
    end
  end
end


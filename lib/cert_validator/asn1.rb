class CertValidator
  class Asn1
    def initialize(der)
      @der = der
    end

    def decode
      @decode ||= OpenSSL::ASN1.decode @der
    end

    def extension_payload
      OpenSSL::ASN1.decode(decode.value.last).value
    end
  end
end

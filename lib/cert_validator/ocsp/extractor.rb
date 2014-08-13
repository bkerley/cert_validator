class CertValidator
  class RealOcspValidator
    class Extractor
      attr_reader :certificate

      def initialize(cert)
        @certificate = cert
      end

      def endpoint
        return nil unless has_ocsp_extension?

        ocsp_extension_payload
      end

      def has_ocsp_extension?
        !! ocsp_extension
      end

      def ocsp_extension
        @ocsp_extension ||= certificate.extensions.detect{ |e| e.oid == 'authorityInfoAccess' }
      end

      def decoded_extension
        @decoded_extension ||= Asn1.new(Asn1.new(ocsp_extension).extension_payload).decode
      end

      def ocsp_extension_payload
        content = decoded_extension.value.detect do |v|
          v.first.value == 'OCSP'
        end.value[1].value
      end
    end
  end
end

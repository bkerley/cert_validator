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
        !! (ocsp_extension && ocsp_extension_payload)
      end

      def ocsp_extension
        @ocsp_extension ||= certificate.extensions.detect{ |e| e.oid == 'authorityInfoAccess' }
      end

      def decoded_extension
        @decoded_extension ||= Asn1.new(Asn1.new(ocsp_extension).extension_payload).decode
      end

      def ocsp_extension_payload
        return @ocsp_extension_payload if defined? @ocsp_extension_payload

        intermediate = decoded_extension.value.detect do |v|
          v.first.value == 'OCSP'
        end.value[1].value

        @ocsp_extension_payload = descend_to_string(intermediate)
      end

      def descend_to_string(asn_data)
        return asn_data if asn_data.is_a? String
        seen = Set.new
        current = asn_data
        loop do
          raise RecursiveExtractError.new if seen.include? current
          seen.add current
          current = current.first.value

          return current if current.is_a? String
        end
      end
    end
  end
end

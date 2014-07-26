class CertValidator
  class CrlValidator
    class Extractor
      attr_reader :certificate

      def initialize(cert)
        @certificate = cert
      end

      def distribution_points
        return [] unless has_crl_extension?
        decoded_payload.value.map{ |v| descend_to_string v.value }
      end

      def has_crl_extension?
        !! crl_extension
      end

      def crl_extension
        @crl_extension ||= certificate.extensions.detect{ |e| e.oid == 'crlDistributionPoints' }
      end

      def crl_extension_payload
        @crl_extension_payload ||= Asn1.new(crl_extension.to_der).extension_payload
      end

      def decoded_payload
        @decoded_payload ||= Asn1.new(crl_extension_payload).decode
      end

      def descend_to_string(asn_data)
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

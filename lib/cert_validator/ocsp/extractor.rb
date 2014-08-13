class CertValidator
  class RealOcspValidator
    class Extractor
      attr_reader :certificate

      def initialize(cert)
        @certificate = cert
      end
    end
  end
end

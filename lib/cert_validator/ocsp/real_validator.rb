class CertValidator
  class RealOcspValidator
    attr_reader :certificate
    attr_reader :ca

    def initialize(cert, ca)
      @certificate = cert
      @ca = ca

      @extractor = Extractor.new @certificate
    end

    def available?
      @extractor.has_ocsp_extension?
    end

    def valid?
      true
    end
  end
end

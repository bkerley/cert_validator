class CertValidator
  class NullOcspValidator
    attr_reader :certificate
    attr_reader :ca
    
    def initialize(_cert, _ca)
    end

    def available?
      false
    end

    def valid?
      raise OcspNotAvailableError.new
    end
  end
end

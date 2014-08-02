class CertValidator
  class Error < StandardError
  end

  class OcspNotAvailableError < Error
    def initialize
      super "OCSP functionality isn't available in this version of Ruby."
    end
  end

  class RecursiveExtractError < Error
    def initialize
      super "Tried to extract a value from a recursive structure. Please file a bug!"
    end
  end

  class CrlFetchError < Error
    def initialize
      super "Couldn't fetch CRL."
    end
  end
end

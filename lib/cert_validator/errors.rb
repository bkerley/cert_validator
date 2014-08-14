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

  module OcspFailures
    class OcspFailure < Error
    end

    class FetchError < OcspFailure
      def initialize
        super "Couldn't fetch OCSP."
      end
    end

    class NonzeroStatus < OcspFailure
      def initialize(status)
        super "OCSP status was #{status}, expected 0"
      end
    end

    class ResponseMismatch < OcspFailure
      def initialize
        super "OCSP response did not match certificate issuer"
      end
    end

    class MissingStatus < OcspFailure
      def initialize
        super "OCSP response was missing status section"
      end
    end

    class UnacceptableNonce < OcspFailure
      def initialize
        super "OCSP response had unacceptable result from nonce check"
      end
    end

    class SerialMismatch < OcspFailure
      def initialize(got, expected)
        super "OCSP response serial was #{got.inspect}, expected #{expected.inspect}"
      end
    end

    class NotValidNow < OcspFailure
      def initialize(validity_range)
        super "OCSP response only valid from #{validity_range.begin} to #{validity_range.end}, currently #{Time.now}"
      end
    end

    class Revoked < OcspFailure
      def initialize
        super "OCSP response indicates cert was revoked"
      end
    end

    class UnexpectedStatus < OcspFailure
      def initialize(got)
        super "OCSP response was #{got.inspect}, expected 0"
      end
    end
  end
end

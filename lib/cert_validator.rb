%w{version errors asn1 crl_validator ocsp}.each { |f| require "cert_validator/#{f}" }

class CertValidator
  attr_reader :certificate
  attr_reader :ca

  def initialize(cert, ca)
    @certificate = cert
    @ca = ca
  end

  def crl=(crl)
    crl_validator.crl = crl
  end

  def crl_available?
    crl_validator.available?
  end

  def crl_valid?
    crl_validator.valid?
  end

  private
  def crl_validator
    @crl_validator ||= CrlValidator.new certificate, ca
  end
end

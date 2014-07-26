%w{version errors asn1 crl_validator}.each { |f| require "cert_validator/#{f}" }

class CertValidator
  attr_reader :certificate

  def initialize(cert)
    @certificate = cert
  end

  def crl=(crl)
    crL_validator.crl = crl
  end

  def crl_available?
    crl_validator.available?
  end

  def crl_valid?
    crl_validator.valid?
  end

  private
  def crl_validator
    @crl_validator ||= CrlValidator.new certificate
  end
end

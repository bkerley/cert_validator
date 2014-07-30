if defined? OpenSSL::OCSP
  require 'cert_validator/ocsp/ocsp_validator.rb'
else
  require 'cert_validator/ocsp/null_validator.rb'

  # use the null validator as a fallback
  CertValidator::OcspValidator = CertValidator::NullOcspValidator
end

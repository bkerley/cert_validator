if defined? OpenSSL::OCSP
  require 'cert_validator/ocsp/real_validator.rb'

  CertValidator::OcspValidator = CertValidator::RealOcspValidator
else
  require 'cert_validator/ocsp/null_validator.rb'

  # use the null validator as a fallback
  CertValidator::OcspValidator = CertValidator::NullOcspValidator
end
2

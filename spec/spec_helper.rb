require 'cert_validator'
%w{certs validator_expectations}.each do |f|
  require_relative "./support/#{f}"
end

RSpec.configure do |config|

  config.include Certs

  unless defined? OpenSSL::OCSP
    config.filter_run_excluding real_ocsp: true
  end
end

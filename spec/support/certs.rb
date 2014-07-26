require 'openssl'

module Certs
  def cert(name)
    OpenSSL::X509::Certificate.new load "#{name}.crt"
  end

  def crl(name)
    OpenSSL::X509::CRL.new load "#{name}.crl"
  end

  private
  def load(filename)
    path = File.join(File.dirname(__FILE__), 'ca', filename)
    File.read path
  end
end

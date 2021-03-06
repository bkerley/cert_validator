require 'r509/certificate_authority/signer'
require 'r509/crl/administrator'
require 'erb'
require_relative 'helper'

namespace :ca do
  desc 'Generate all the certificates for testing'
  task :all => %w{ good ocsp_only crl_only empty revoked }

  task :clean do
    Dir.chdir 'spec/support/ca' do
      sh 'rm -f *.crt *.crl *.key *.txt *.yaml'
    end
  end

  desc 'Generate a signing CA for testing certificates'
  task :root => 'spec/support/ca/root.key'
  file 'spec/support/ca/root.key' do |t|
    subject = OpenSSL::X509::Name.new
    'C=US/ST=Florida/L=Miami/O=r509-cert-validator/CN='.split('/').each do |s|
      key, value = s.split '=', 2
      subject.add_entry key, value
    end
    csr = CaHelper.csr
    cert = R509::CertificateAuthority::Signer.selfsign(
                                                       csr: csr,
                                                       not_after: (Time.now.to_i + (86400 * 3650)),
                                                       message_digest: 'sha1'
                                                       )
    
    csr.key.write_pem 'spec/support/ca/root.key'
    cert.write_pem 'spec/support/ca/root.crt'

    sh "touch spec/support/ca/rcv_spec_list.txt"
    sh "touch spec/support/ca/rcv_spec_crlnumber.txt"
  end
  file 'spec/support/ca/root.crt' => 'spec/support/ca/root.key'
  file 'spec/support/ca/rcv_spec_list.txt' => 'spec/support/ca/root.key'
  file 'spec/support/ca/rcv_spec_crlnumber.txt' => 'spec/support/ca/root.key'

  file 'spec/support/ca/config.yaml' => 'spec/support/ca/config.yaml.erb' do |s|
    erb = ERB.new File.read s.prerequisites.first
    b = binding
    cert_path = File.expand_path 'spec/support/ca/'
    File.open s.name, 'w' do |f|
      f.write erb.result b
    end
  end

  desc 'Generate a valid certificate with CRL and OCSP data'
  task :good => 'spec/support/ca/good.crt'
  file 'spec/support/ca/good.crt' => [:root, 'spec/support/ca/config.yaml'] do
    ca = CaHelper.ca
    csr = CaHelper.options_builder.build_and_enforce(
                                                     csr: CaHelper.csr,
                                                     profile_name: 'good'
                                                     )

    cert = ca.sign csr
    cert.write_pem 'spec/support/ca/good.crt'
  end

  desc 'Generate a valid certificate with only CRL data'
  task :crl_only => 'spec/support/ca/crl_only.crt'
  file 'spec/support/ca/crl_only.crt' => [:root, 'spec/support/ca/config.yaml'] do |t|
    ca = CaHelper.ca
    csr = CaHelper.options_builder.build_and_enforce(
                                                     csr: CaHelper.csr,
                                                     profile_name: 'crl_only'
                                                     )
    cert = ca.sign csr
    cert.write_pem 'spec/support/ca/crl_only.crt'
  end

  desc 'Generate a valid certificate with only OCSP data'
  task :ocsp_only => 'spec/support/ca/ocsp_only.crt'
  file 'spec/support/ca/ocsp_only.crt' => [:root, 'spec/support/ca/config.yaml'] do |t|
    ca = CaHelper.ca
    csr = CaHelper.options_builder.build_and_enforce(
                                                     csr: CaHelper.csr,
                                                     profile_name: 'ocsp_only'
                                                     )
    cert = ca.sign csr
    cert.write_pem 'spec/support/ca/ocsp_only.crt'
  end

  desc 'Generate a certificate and revoke it in both CRL and OCSP'
  task :revoked => 'spec/support/ca/revoked.crt'
  file 'spec/support/ca/revoked.crt' => [:root, 'spec/support/ca/config.yaml'] do |t|
    ca = CaHelper.ca
    csr = CaHelper.options_builder.build_and_enforce(
                                                     csr: CaHelper.csr,
                                                     profile_name: 'good'
                                                     )

    cert = ca.sign csr
    cert.write_pem 'spec/support/ca/revoked.crt'

    admin = R509::CRL::Administrator.new CaHelper.pool['rcv_spec_ca']
    admin.revoke_cert cert.serial
    crl = admin.generate_crl
    crl.write_pem 'spec/support/ca/rcv_spec.crl'
  end

  desc 'Generate a valid certificate with no CRL or OCSP data'
  task :empty => 'spec/support/ca/empty.crt'
  file 'spec/support/ca/empty.crt' => [:root, 'spec/support/ca/config.yaml'] do
    ca = CaHelper.ca
    cert = ca.sign csr: CaHelper.csr
    cert.write_pem 'spec/support/ca/empty.crt'
  end
end

require 'cert_validator/ocsp/extractor'

describe CertValidator::RealOcspValidator::Extractor do
  it 'accepts a certificate on construction' do
    expect{ described_class.new cert 'good' }.to_not raise_error
  end

  describe 'with one OCSP endpoint' do
    subject { described_class.new cert 'good' }

    it 'extracts the OCSP endpoint' do
      expect(subject.endpoint).to eq 'http://localhost:22022/crl'
    end
  end

  describe 'with no OCSP endpoint' do
    subject { described_class.new cert 'crl_only' }

    it 'extracts no OCSP endpoint' do
      expect(subject.endpoint).to be_nil
    end
  end
end

describe CertValidator::CrlValidator do
  subject { described_class.new good_cert }
  let(:good_cert){ cert 'good' }
  let(:crl_data){ crl 'revoked' }

  it 'accepts a certificate on construction' do
    expect{ described_class.new good_cert }.to_not raise_error
  end

  it 'accepts OpenSSL CRL data to replace hitting a URL for it' do
    expect{ subject.crl = crl_data }.to_not raise_error
    expect(subject.available?).to be
  end

  describe 'with given CRL data' do
    subject do
      described_class.new(good_cert).tap do |v|
        v.crl = crl_data
      end
    end

    it 'postively validates a non-revoked cert against a correct CRL' do
      expect(subject.valid?).to be
    end
  end
end

describe CertValidator::CrlValidator do
  subject { described_class.new good_cert }
  let(:good_cert){ cert 'good' }
  let(:revoked_cert){ cert 'revoked' }
  let(:crl_data){ crl 'revoked' }

  it 'accepts a certificate on construction' do
    expect{ described_class.new good_cert }.to_not raise_error
  end

  it 'accepts OpenSSL CRL data to replace hitting a URL for it' do
    expect{ subject.crl = crl_data }.to_not raise_error
    expect(subject.available?).to be
  end

  describe 'with a good cert and matching CRL data' do
    subject do
      described_class.new(good_cert).tap do |v|
        v.crl = crl_data
      end
    end

    it { is_expected.to be_available }
    it { is_expected.to be_valid }
  end

  describe 'with a revoked cert and matching CRL data' do
    subject do
      described_class.new(revoked_cert).tap do |v|
        v.crl = crl_data
      end
    end

    it { is_expected.to be_available }
    it { is_expected.to_not be_valid }
  end

  describe 'with irrelevant CRL data' do
    it { is_expected.to be_available }
    it { is_expected.to_not be_valid }
  end

  describe 'with no CRL data' do
    it { is_expected.to_not be_available }
    it { is_expected.to_not be_valid }
  end
end

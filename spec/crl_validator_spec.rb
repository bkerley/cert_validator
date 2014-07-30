describe CertValidator::CrlValidator do
  subject { described_class.new good_cert, ca }
  let(:ca){ cert 'root' }
  let(:good_cert){ cert 'good' }
  let(:revoked_cert){ cert 'revoked' }
  let(:empty_cert){ cert 'empty' }
  let(:crl_data){ crl 'revoked' }
  let(:mismatched_crl_data){ crl 'mismatched' }

  it 'accepts a certificate on construction' do
    expect{ described_class.new good_cert, ca }.to_not raise_error
  end

  it 'accepts OpenSSL CRL data to replace hitting a URL for it' do
    expect{ subject.crl = crl_data }.to_not raise_error
    expect(subject.available?).to be
  end

  describe 'with a good cert and matching CRL data' do
    subject do
      described_class.new(good_cert, ca).tap do |v|
        v.crl = crl_data
      end
    end

    it { is_expected.to be_available }
    it { is_expected.to be_valid }
  end

  describe 'with a revoked cert and matching CRL data' do
    subject do
      described_class.new(revoked_cert, ca).tap do |v|
        v.crl = crl_data
      end
    end

    it { is_expected.to be_available }
    it { is_expected.to_not be_valid }
  end

  describe 'with irrelevant CRL data' do
    subject do
      described_class.new(good_cert, ca).tap do |v|
        v.crl = mismatched_crl_data
      end
    end
    it { is_expected.to be_available }
    it { is_expected.to_not be_valid }
  end

  describe 'with no CRL data' do
    subject do
      described_class.new(empty_cert, ca)
    end

    it { is_expected.to_not be_available }
    it { is_expected.to_not be_valid }
  end
end

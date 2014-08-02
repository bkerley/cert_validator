
describe CertValidator::OcspValidator, real_ocsp: true do
  subject{ described_class.new good_cert, ca }
  let(:ca){ cert 'root' }
  let(:good_cert){ cert 'good' }

  it 'accepts a certificate and CA on construction' do
    expect{ described_class.new good_cert, ca }.to_not raise_error
  end

  describe 'with a good cert' do
    it { is_expected.to be_available }
    it { is_expected.to be_valid }
  end

  describe 'with a revoked cert' do
    it { is_expected.to be_available }
    it { is_expected.to_not be_valid }
  end

  describe 'with an irrelevant OCSP response' do
    it { is_expected.to be_available }
    it { is_expected.to_not be_valid }
  end

  describe 'with a cert with no OCSP data' do
    it { is_expected.to_not be_available }
    it { is_expected.to_not be_valid }
  end
end

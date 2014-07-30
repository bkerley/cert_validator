require 'cert_validator/ocsp/null_validator'

describe CertValidator::NullOcspValidator do
  subject{ described_class.new good_cert, ca }
  let(:ca){ cert 'root' }
  let(:good_cert){ cert 'good' }

  it 'accepts a certificate and CA on construction' do
    expect{ described_class.new good_cert, ca }.to_not raise_error
  end

  describe 'with a good cert and CA' do
    it { is_expected.to_not be_available }
    it { is_expected.to_not be_valid }
  end
end

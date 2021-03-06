describe CertValidator do
  subject{ described_class.new good_cert, ca }
  let(:good_cert){ cert 'good' }
  let(:ca){ cert 'root' }

  it 'accepts a certificate on construction' do
    expect{ described_class.new good_cert, ca }.to_not raise_error
  end
  it 'provides read-only access to the certificate' do
    expect(subject.certificate).to eq good_cert
  end

  describe 'CRL functionality' do
    let(:matched_crl_validator) do
      described_class.new(good_cert, ca).tap do |validator|
        validator.crl = crl 'revoked'
      end
    end

    let(:mismatched_crl_validator) do
      described_class.new(good_cert, ca).tap do |validator|
        validator.crl = crl 'mismatched'
      end
    end

    let(:revoked_crl_validator) do
      described_class.new(cert('revoked'), ca).tap do |validator|
        validator.crl = crl 'revoked'
      end
    end
    
    it 'returns if CRL validation is available or not' do
      expect(subject.crl_available?).to be
    end

    it 'positively valdiates a correct CRL' do
      expect(matched_crl_validator.crl_valid?).to be
    end

    it 'negatively validates a mismatched CRL' do
      expect(mismatched_crl_validator.crl_valid?).to_not be
    end

    it 'negatively validates a revoked certificate' do
      expect(revoked_crl_validator.crl_valid?).to_not be
    end
  end

  describe 'OCSP functionality' do
    it 'returns if OCSP validation is available or not' do
      expect(subject.ocsp_available?).to eq(true).or eq(false)
    end

    describe 'when available', real_ocsp: true do
      it 'positively validates a non-revoked OCSP response' do
        v = described_class.new cert('good'), ca
        expect(v.ocsp_valid?).to be
      end
      pending 'negatively validates a mismatched OCSP response'

      it 'negatively validates a revoked certificate' do
        v = described_class.new cert('revoked'), ca
        expect(v.ocsp_valid?).to_not be
      end
    end

    describe 'when not available', null_ocsp: true do
      it 'raises when asked to validate OCSP' do
        expect{ subject.ocsp_valid? }.to raise_error CertValidator::OcspNotAvailableError
      end
    end
  end
end

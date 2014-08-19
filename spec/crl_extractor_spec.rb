describe CertValidator::CrlValidator::Extractor do
  let(:good_cert){ cert 'good' }

  it 'accepts a certificate on construction' do
    expect{ described_class.new good_cert }.to_not raise_error
  end

  describe 'with multiple distribution points' do
    subject{ described_class.new cert 'github' }

    it 'extracts the CRL distribution points' do
      points = nil
      expect{ points = subject.distribution_points }.to_not raise_error

      expect(points).to be_an Enumerable
      expect(points.length).to eq 2

      expect(points).to include 'http://crl3.digicert.com/sha2-ev-server-g1.crl'
      expect(points).to include 'http://crl4.digicert.com/sha2-ev-server-g1.crl'
    end
  end

  describe 'with one distribution point' do
    subject{ described_class.new good_cert }

    it 'extracts the CRL distribution point' do
      points = nil
      expect{ points = subject.distribution_points }.to_not raise_error
      expect(points).to eq ['http://cert-validator-test.herokuapp.com/revoked.crl']
    end
  end

  describe 'with no distribution points' do
    subject{ described_class.new cert 'ocsp_only' }

    it 'extracts no CRL distribution points' do
      points = nil
      expect{ points = subject.distribution_points }.to_not raise_error
      expect(points).to be_empty
    end
  end
end

# CertValidator

Validate an X509 certificate against its CRL or OCSP endpoint. Raise exceptions
if OCSP isn't available.

## Compatibility

This project aims for compatibility with:

* Ruby 1.9.3
* Ruby 2.0
* Ruby 2.1
* JRuby 1.7 in Ruby 1.9 and 2.0 modes

## Installation

Add this line to your application's Gemfile:

    gem 'cert_validator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cert_validator

## Usage

```ruby
some_cert # an OpenSSL::X509::Certificate

validator = CertValidator.new some_cert

validator.crl_available? # return true if certificate has a CRL endpoint

validator.crl_valid? # validate against the certificate's CRL endpoint

validator.crl_file = some_path # allow overriding the CRL

# return true if certificate has an OCSP endpoint and the Ruby OpenSSL module
# supports OCSP
validator.ocsp_available?

validator.ocsp_valid? # validate against the certificate's OCSP endpoint
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/cert_validator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

module ValidatorExpectations
  RSpec::Matchers.define :be_available do
    match do |actual|
      actual.available?
    end
  end

  RSpec::Matchers.define :be_valid do
    match do |actual|
      actual.valid?
    end
  end
end

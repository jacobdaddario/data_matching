require "data_grouping/abstract_matcher"

RSpec.describe DataGrouping::AbstractMatcher do
  let(:headers) { ["Email", "Name", "email_address"] }

  subject { described_class.new(headers) }

  describe "#initialize" do
    it "raises `NotImplementedError` when `#header_regex` is not defined" do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe "#match?" do
    let(:source_value) { "foo" }
    let(:compared_value) { "bar" }

    it "raises `NotImplementedError` when `#normalize` is not defined" do
      expect { subject.match?(source_value, compared_value) }.to raise_error(NotImplementedError)
    end
  end
end

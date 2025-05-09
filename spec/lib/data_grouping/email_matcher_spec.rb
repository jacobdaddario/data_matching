require "data_grouping/email_matcher"

RSpec.describe DataGrouping::EmailMatcher do
  let(:headers) { ["Email", "Name", "EmailAddress", "Other"] }

  subject { described_class.new(headers) }

  describe "#initialize" do
    it "assigns only headers matching /Email/ to checked_headers" do
      expect(subject.checked_headers).to eq(["Email", "EmailAddress"])
    end
  end

  describe "#match?" do
    let(:source_value) { "test@Example.com" }
    let(:compared_value) { "TEST@example.COM" }

    it "returns true if normalized values are equal" do
      expect(subject.match?(source_value, compared_value)).to be true
    end

    context "if either value is blank" do
      it "returns false if source_value is blank" do
        expect(subject.match?("", compared_value)).to be false
      end

      it "returns false if compared_value is blank" do
        expect(subject.match?(source_value, nil)).to be false
      end
    end
  end

  describe "#normalize" do
    it "downcases email addresses" do
      expect(subject.normalize("Foo@EXAMPLE.com")).to eq("foo@example.com")
    end
  end
end

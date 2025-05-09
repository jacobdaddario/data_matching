require "data_grouping/phone_and_email_matcher"

RSpec.describe DataGrouping::PhoneAndEmailMatcher do
  let(:headers) { ["Email", "Name", "Phone", "Other", "EmailAddress", "PhoneNumber"] }

  subject { described_class.new(headers) }

  describe "#initialize" do
    it "assigns only headers matching /(Email|Phone)/ to checked_headers" do
      expect(subject.checked_headers).to eq(["Email", "Phone", "EmailAddress", "PhoneNumber"])
    end
  end

  describe "#match?" do
    context "when values are phone numbers" do
      let(:source_value) { "(123) 456-7890" }
      let(:compared_value) { "1234567890" }

      it "returns true if normalized phone numbers are equal" do
        expect(subject.match?(source_value, compared_value)).to be true
      end
    end

    context "when values are emails" do
      let(:source_value) { "Test@Example.com" }
      let(:compared_value) { "test@example.com" }

      it "returns true if normalized emails are equal" do
        expect(subject.match?(source_value, compared_value)).to be true
      end
    end

    context "if either value is blank" do
      let(:source_value) { "test@example.com" }
      let(:compared_value) { "" }

      it "returns false if compared_value is blank" do
        expect(subject.match?(source_value, compared_value)).to be false
      end

      it "returns false if source_value is blank" do
        expect(subject.match?("", compared_value)).to be false
      end
    end
  end

  describe "#normalize" do
    context "when value is a phone number" do
      it "removes non-digit characters from phone numbers" do
        expect(subject.normalize("(333) 222-1111")).to eq("3332221111")
      end
    end

    context "when value is an email" do
      it "downcases email addresses" do
        expect(subject.normalize("Test@Example.com")).to eq("test@example.com")
      end
    end
  end
end

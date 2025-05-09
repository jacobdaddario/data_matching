require "data_grouping/phone_matcher"

RSpec.describe DataGrouping::PhoneMatcher do
  let(:headers) { ["Phone", "Name", "Fax", "Phone number"] }

  subject { described_class.new(headers) }

  describe "#initialize" do
    it "assigns only headers matching /Phone/ to checked_headers" do
      expect(subject.checked_headers).to eq(["Phone", "Phone number"])
    end
  end

  describe "#match?" do
    let(:source_value) { "(555) 123-4567" }
    let(:compared_value) { "5551234567" }

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
    it "removes non-digit characters from phone numbers" do
      expect(subject.normalize("(555) 123-4567")).to eq("5551234567")
      expect(subject.normalize("555.888.9999 ext 123")).to eq("5558889999123")
    end
  end
end

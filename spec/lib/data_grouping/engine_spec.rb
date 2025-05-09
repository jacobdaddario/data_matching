require "data_grouping"
require "debug"

RSpec.describe DataGrouping::Engine do
  let(:headers) { ["Name", "Phone", "Email"] }
  let(:csv_data) do
    <<~CSV
      Name,Phone,Email
      Alice,(123) 456-7890,alice@example.com
      Bob,1234567890,bob@example.com
      Charlie,1112223333,charlie@example.com
    CSV
  end
  let(:filename) { "test" }
  let(:filepath) { "../../data/#{filename}.csv" }
  let(:matcher) { "phone" }

  before do
    allow(File).to receive(:write)
    allow(File).to receive(:read).and_return(csv_data)
  end

  subject { described_class.new(filename: filename, matcher: matcher) }

  describe "#initialize" do
    context "when filename contains disallowed patterns" do
      let(:filename) { "../hack" }

      it "raises an ArgumentError" do
        expect { subject }.to raise_error(ArgumentError, /Only allowed to access data files/)
      end
    end

    context "when matcher is invalid" do
      let(:matcher) { "invalid" }

      it "raises an ArgumentError" do
        expect { subject }.to raise_error(ArgumentError, /Must supply a valid matcher/)
      end
    end

    it "loads the CSV file and sets table headers including id" do
      expect(subject.instance_variable_get(:@table).headers).to include("id", *headers)
    end
  end

  describe "#run" do
    # Silencing STDOUT so that we don't have specs polluting the test output
    before do
      @original_stdout = $stdout
      $stdout = File.open(File::NULL, "w")
    end

    after do
      $stdout.close
      $stdout = @original_stdout
    end

    it "writes the result CSV with the id column populated correctly" do
      result = subject.run

      expect(File).to have_received(:write).with(anything, result.to_csv)

      expect(result[0]["id"]).not_to be_nil
      expect(result[1]["id"]).not_to be_nil
      expect(result[0]["id"]).to eq result[1]["id"]

      expect(result[2]["id"]).not_to be_nil
      expect(result[0]["id"]).not_to eq result[2]["id"]
    end
  end
end

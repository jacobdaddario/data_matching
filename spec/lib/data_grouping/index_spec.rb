require "data_grouping/index"
require "data_grouping/abstract_matcher"

RSpec.describe DataGrouping::Index do
  let(:headers) { ["A"] }
  let(:matcher) { instance_double(DataGrouping::AbstractMatcher, checked_headers: headers) }
  let(:table) do
    [
      {"A" => "foo", "B" => "bar"},
      {"A" => "baz", "B" => nil},
      {"A" => "bar", "B" => "qux"}
    ]
  end
  let(:expected_index) do
    [
      {table_index: 0, value: "foo"},
      {table_index: 1, value: "baz"},
      {table_index: 2, value: "bar"}
    ]
  end

  before do
    allow(matcher).to receive(:normalize) { |value| value }
  end

  subject { described_class.new(table, matcher) }

  describe "#build_index" do
    it "builds the index with the correct entries sorted by value in descending order" do
      index = subject.build_index.index

      expect(index).to all(include(:table_index, :value))
      expect(index).to eq(expected_index)
    end

    context "when table rows have nil values" do
      let(:table) do
        [
          {"A" => nil, "B" => nil},
          {"A" => "y", "B" => nil}
        ]
      end
      let(:expected_index) do
        [
          {table_index: 1, value: "y"},
          {table_index: 0, value: ""}
        ]
      end

      it "substitutes nils with empty strings and forces them to the end of the list" do
        index = subject.build_index.index

        expect(index).to eq(expected_index)
      end
    end

    context "when there are multiple headers" do
      let(:headers) { ["A", "B"] }
      let(:table) do
        [
          {"A" => "apple", "B" => "xray"},
          {"A" => "banana", "B" => "zulu"},
          {"A" => "apple", "B" => "alpha"},
          {"A" => "banana", "B" => "yankee"},
          {"A" => "apricot", "B" => "charlie"}
        ]
      end
      let(:expected_index) do
        [
          {table_index: 1, value: "zulu"},
          {table_index: 3, value: "yankee"},
          {table_index: 0, value: "xray"},
          {table_index: 4, value: "charlie"},
          {table_index: 1, value: "banana"},
          {table_index: 3, value: "banana"},
          {table_index: 4, value: "apricot"},
          {table_index: 0, value: "apple"},
          {table_index: 2, value: "apple"},
          {table_index: 2, value: "alpha"}
        ]
      end

      it "creates index entries for each header value" do
        index = subject.build_index.index

        expect(index).to eq(expected_index)
      end
    end
  end

  describe "#each_with_index" do
    let(:index_double) { [] }

    before do
      subject.instance_variable_set(:@index, index_double)
      allow(index_double).to receive(:each_with_index)
    end

    it "delegates the method to @index" do
      subject.each_with_index {}

      expect(index_double).to have_received(:each_with_index)
    end
  end

  describe "#length" do
    let(:index_double) { [] }

    before do
      subject.instance_variable_set(:@index, index_double)
      allow(index_double).to receive(:length)
    end

    it "delegates the method to @index" do
      subject.length

      expect(index_double).to have_received(:length)
    end
  end
end

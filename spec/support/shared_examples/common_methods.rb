# frozen_string_literal: true

RSpec.shared_examples "common methods" do
  describe ".many" do
    it "returns an array of serialized resources" do
      serialized_resources = subject.many(resources)

      expect(serialized_resources).to be_an(Array)
      expect(serialized_resources.size).to eq(resources.size)
      expect(serialized_resources.first).to eq(subject.new(resources.first).as_json)
    end
  end

  describe ".one" do
    it "returns a serialized resource" do
      serialized_resource = subject.one(resource)

      expect(serialized_resource).to eq(subject.new(resource).as_json)
    end
  end
end

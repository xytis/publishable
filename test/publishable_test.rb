require "test_helper"

class PublishableTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert Publishable::VERSION
  end

  test "model responds to methods" do
    example = PublishablePostBoolean.new
    example.publish
  end
end

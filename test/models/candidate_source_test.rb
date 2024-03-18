# frozen_string_literal: true

require "test_helper"

class CandidateSourceTest < ActiveSupport::TestCase
  test "should create candidate source" do
    candidate_source = CandidateSource.create!(name: "Test     Source    ")

    assert_equal candidate_source.name, "Test Source"
  end
end

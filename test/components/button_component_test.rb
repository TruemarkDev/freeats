# frozen_string_literal: true

require "test_helper"

class ButtonComponentTest < ViewComponent::TestCase
  test "default button component" do
    assert_equal(
      render_inline(ButtonComponent.new.with_content("Button")).to_html,
      %(<button class="btn d-inline-flex gap-2 align-items-center justify-content-center
        text-nowrap btn-primary btn-medium" type="submit">Button</button>).squish
    )
  end
end

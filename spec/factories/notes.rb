FactoryBot.define do
  factory :note do
    editor { create(:editor) }
    model { create(:review_pending_model) }
    sequence(:comment) {|n| "Testing editor notes #{n}" }
  end
end
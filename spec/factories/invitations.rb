FactoryBot.define do
  factory :invitation do
    model { create(:model) }
    editor { create(:editor) }

    trait :pending do
      state { 'pending' }
    end

    trait :accepted do
      state { 'accepted' }
    end

    trait :expired do
      state { 'expired' }
    end
  end
end

FactoryBot.define do
  factory :model do
    title             { 'arfon / fidgit' }
    body              { 'An ungodly union of GitHub and Figshare http://fidgit.arfon.org' }
    repository_url    { 'http://github.com/arfon/fidgit' }
    archive_doi       { 'https://doi.org/10.0001/zenodo.12345' }
    software_version  { 'v1.0.0' }
    submitting_author { create(:user) }
    submission_kind   { 'new' }
    suggested_editor  { '@editor' }

    created_at  { Time.now }
    updated_at  { Time.now }

    factory :model_with_sha do
      sha { '48d24b0158528e85ac7706aecd8cddc4' }
    end

    model_metadata = { 'model' => { 'languages' => ['Ruby', 'Rust'],
                                    'editor' => '@arfon',
                                    'title' => 'arfon / fidgit',
                                    'reviewers' => ['@jim', '@jane'],
                                    'authors' => [{'given_name' =>  'Mickey', 'last_name' => 'Mouse', 'orcid' => '0000-0002-7736-0000'},
                                                  {'given_name' => 'Walt', 'middle_name' => 'Elias', 'last_name' => 'Disney', 'orcid' => '0000-0002-7736-000X'}]}}
    factory :accepted_model do
      metadata { model_metadata }
      state { 'accepted' }
      accepted_at { Time.now }
      review_issue_id { 0 }
      doi { '10.21105/joss.00000' }
    end

    factory :submitted_model do
      state { 'submitted' }
    end

    factory :resubmission_model do
      submission_kind   { 'resubmission' }
    end

    factory :rejected_model do
      state { 'rejected' }
    end

    factory :retracted_model do
      metadata { model_metadata }
      state { 'retracted' }
      accepted_at { Time.now }
      review_issue_id { 0 }
      doi { '10.21105/joss.00000' }
    end

    factory :submitted_model_with_sha do
      sha { '48d24b0158528e85ac7706aecd8cddc4' }
      state { 'submitted' }
    end

    factory :review_pending_model do
      sha { '48d24b0158528e85ac7706aecd8cddc4' }
      state { 'review_pending' }
      meta_review_issue_id { 100 }
    end

    factory :under_review_model do
      sha { '48d24b0158528e85ac7706aecd8cddc4' }
      state { 'under_review' }
      meta_review_issue_id { 100 }
      review_issue_id { 101 }
    end
  end
end

require 'net/ftp'

namespace :portico do
  desc "Deposit"
  task deposit: :environment do
    Model.visible.not_archived.each do |model|
      # Upload to FTP server
      Net::FTP.open(ENV['PORTICO_HOST'], ENV['PORTICO_USERNAME'], ENV['PORTICO_PASSWORD']) do |ftp|
        if ftp.list("10.21105.#{model.joss_id}.zip").any?
          puts "Deposit already exists for 10.21105.#{model.joss_id}"
        else
          crossref_file = "https://github.com/#{Rails.application.settings["models_repo"]}/raw/master/#{model.joss_id}/10.21105.#{model.joss_id}.crossref.xml"
          pdf_file = "https://github.com/#{Rails.application.settings["models_repo"]}/raw/master/#{model.joss_id}/10.21105.#{model.joss_id}.pdf"

          files_to_download = [crossref_file, pdf_file]

          # Create folder
          `mkdir tmp/10.21105.#{model.joss_id}`

          # Download the files into this folder
          files_to_download.each do |file|
            `cd tmp/10.21105.#{model.joss_id} && { curl -L -O #{file} ; cd -; }`
          end

          # Archive the review too...
          archive_review_object = Hash.new
          archive_review_object['review_issue'] = GITHUB.issue(Rails.application.settings["reviews"], model.review_issue_id).to_h
          archive_review_object['review_issue_comments'] = GITHUB.issue_comments(Rails.application.settings["reviews"], model.review_issue_id).map(&:to_h)

          File.open("tmp/10.21105.#{model.joss_id}/review.json", "w") { |f|
            f.write(JSON.pretty_generate(archive_review_object))
          }

          # Zip the folder
          `zip tmp/10.21105.#{model.joss_id}.zip tmp/10.21105.#{model.joss_id}/*`
          ftp.putbinaryfile("tmp/10.21105.#{model.joss_id}.zip")
          puts "Uploading deposit for 10.21105.#{model.joss_id}"

          # Clean up
          `rm -rf tmp/10.21105.#{model.joss_id}*`

          # Update the model
          model.update_attribute(:archived, true)
        end
      end
    end
  end
end

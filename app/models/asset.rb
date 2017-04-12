class Asset < ActiveRecord::Base
  #belongs_to :owner, :polymorphic => true
  #has_attached_file :avatar, :styles => {:medium => "300x300>", :thumb => "100x100>"}, :url => "/system/:attachment/:id/:style/:basename.:extension",
  #                  :path => ":rails_root/public/system/:attachment/:id/:style/:basename.:extension"


  has_attached_file :avatar, :styles => {:medium => "250x250>", :thumb => "100x100>"},
                    :content_type => {:content_type => ["image/jpeg", "image/gif", "image/png", "image/jpg"]},
                    :path => ":attachment/:id/:style/:basename.:extension",
                    :storage => :s3,
                    :s3_credentials => {
                        :bucket => "hookahbutler",
                        :access_key_id => "AKIAJG66MZBPOYB72APA",
                        :secret_access_key => "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"
                    }
end

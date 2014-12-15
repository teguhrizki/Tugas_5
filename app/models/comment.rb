class Comment < ActiveRecord::Base
	#name relation must singular
    before_create :default_status

    belongs_to :article

    belongs_to :user

    validates :content, presence: true, length: { minimum: 10 }


    def default_status

        self.status = "not active"

    end
end

class Article < ActiveRecord::Base
  #name relation must plural
  has_many :comments, dependent: :destroy
  
	has_attached_file :image, 

	:path => ":rails_root/public/system/:attachment/:id/:basename_:style.:extension",
  :url => "/system/:attachment/:id/:basename_:style.:extension",

	:styles => { :medium => "300x300>", :thumb => "100x100>" }

	validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  validates :title, presence: true,
  length: { minimum: 5 }

  validates :content, presence: true,
  length: { minimum: 10 }

  validates :status, presence: true

  def self.to_csv(option = {})
    CSV.generate(option) do |csv|
      csv << column_names
      all.each do |article|
        csv << article.attributes.values_at(*column_names)
      end
    end
  end

  

def self.import(file)
  allowed_attributes = [ "title","content","status"]
  spreadsheet = open_spreadsheet(file)
  header = spreadsheet.row(1)
  (2..spreadsheet.last_row).each do |i|
    row = Hash[[header, spreadsheet.row(i)].transpose]
    product = find_by_id(row["id"]) || new
    product.attributes = row.to_hash.select { |k,v| allowed_attributes.include? k }
    product.save!
  end
end


end

class ArticleImport
# switch to ActiveModel::Model in Rails 4
	extend ActiveModel::Naming
	include ActiveModel::Conversion
	include ActiveModel::Validations
	attr_accessor :file

	def initialize(attributes = {})
		attributes.each { |name, value| send("#{name}=", value) }
	end

	def persisted?
		false
	end

	def save
		if imported_articles.map(&:valid?).all?
			imported_articles.each(&:save!)
			true
		else
			imported_articles.each_with_index do |article, index|
				article.errors.full_messages.each do |message|
					errors.add :base, "Row #{index+2}: #{message}"
				end
			end
			false
		end
	end

	def imported_articles
		@imported_articles ||= load_imported_articles
	end

	def load_imported_articles
		spreadsheet = open_spreadsheet
		header = spreadsheet.row(1)
		(2..spreadsheet.last_row).map do |i|
			row = Hash[[header, spreadsheet.row(i)].transpose]
			article = Article.find_by_id(row["id"]) || Article.new
			article.attributes = row.to_hash.slice(*Article.accessible_attributes)
			article
		end
	end
	
	def open_spreadsheet
		case File.extname(file.original_filename)
		when ".csv" then Csv.new(file.path, nil, :ignore)
		when ".xls" then Excel.new(file.path, nil, :ignore)
		when ".xlsx" then Excelx.new(file.path, nil, :ignore)
		else raise "Unknown file type: #{file.original_filename}"
		end
	end
end
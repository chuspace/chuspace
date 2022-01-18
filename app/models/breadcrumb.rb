class Breadcrumb < ActiveType::Object
  attribute :name, :string
  attribute :path, :string

  validates :name, presence: true

  def link?
    path.present?
  end
end

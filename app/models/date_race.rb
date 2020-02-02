class DateRace
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute date: :string

  def self.all
    Race.select(:date).
        distinct.
        order(date: 'desc')
  end
end
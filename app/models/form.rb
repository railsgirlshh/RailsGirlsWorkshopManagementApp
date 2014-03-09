class Form
  include MongoMapper::Document
  many :registrations, :as => :form

  key :structure,		Object
  belongs_to :workshop

  timestamps!

  def self.by_type(type)
    if type == "coach"
      CoachForm.new
    elsif type == "participant"
      ParticipantForm.new
    else
      raise "Invalid Form type '#{type}' given."
    end
  end
end

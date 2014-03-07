class CoachForm < Form
  def type
    "coach"
  end

  # Workaround for Single Table Inheritance models not having proper path
  # helpers. Found here: http://stackoverflow.com/questions/4507149
  def self.model_name
    Form.model_name
  end
end

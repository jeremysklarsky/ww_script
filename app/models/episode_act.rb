class EpisodeAct < ApplicationRecord
  belongs_to :episode
  belongs_to :act

  has_many :scenes

  def characters
    self.scenes.collect{|s| s.characters}
  end

  def locations
    self.scenes.collect {|s| s.location}
  end
end

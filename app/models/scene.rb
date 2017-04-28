class Scene < ApplicationRecord
  belongs_to :location
  belongs_to :episode_act

  delegate :episode, :to => :episode_act, :allow_nil => false

  has_many :scene_characters
  has_many :characters, :through => :scene_characters

  has_many :lines

  def word_count
    self.lines.collect{|l| l.text.split.size}.inject(:+)
  end

  def self.most_words
    Scene.all.sort_by{|s| s.word_count}.reverse
  end

  def self.longest_two_person
    scenes = Scene.select {|s| s.characters.length == 2}
    scenes.sort_by {|s| s.word_count}.reverse
  end
end

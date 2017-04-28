class Act < ApplicationRecord
  has_many :episode_acts
  has_many :episodes, :through => :episode_acts

  def self.teaser_frequent_character(limit=20)
    teaser = self.find_by_name("TEASER")
    characters = teaser.episode_acts.collect {|a| a.characters}.flatten
    characters.each_with_object(Hash.new(0)) { |word,counts| counts[word.name] += 1 }
      .sort_by {|k,v| v}
      .reverse
      .first(limit)
      .to_h
  end

  def self.teaser_frequent_location(limit=10)
    teaser = self.find_by_name("TEASER")
    locations = teaser.episode_acts.collect {|a| a.locations}.flatten
    locations.each_with_object(Hash.new(0)) { |word,counts| counts[word.name] += 1 }
      .sort_by {|k,v| v}
      .reverse
      .first(limit)
      .to_h
  end
end

class Location < ApplicationRecord

  has_many :episode_locations
  has_many :episodes, :through => :episode_locations

  has_many :lines

  has_many :location_characters
  has_many :characters, :through => :location_characters

  def self.most_lines(limit=10)
    Line.group(:location).count.sort_by{|k,v| v}.reverse.first(limit).to_h
  end

  def top_characters(limit=10)
    Line.where(:location => self).group(:character).count.sort_by{|k,v| v}.reverse.first(limit).to_h
  end

  def self.find_by_term(term)
    binding.pry
  end


  def self.top_oval_characters_by_scene
    oval_locations = self.where("name LIKE ?", "%oval%").where.not("name LIKE ?", "%out%")
    oval_locations.collect {|l| l.lines}.flatten.collect{|l| l.character}.each_with_object(Hash.new(0)) { |word,counts| counts[word.name] += 1 }.sort_by{|k,v| v}.reverse.first(20).to_h
  end

  def self.most_walk_and_talks
    hallways = self.where("name LIKE ?", "%hallway%")
    hallways.collect {|l| l.lines}.flatten.collect{|l| l.character}.each_with_object(Hash.new(0)) { |word,counts| counts[word.name] += 1 }.sort_by{|k,v| v}.reverse.first(20).to_h
  end

  def self.most_scenes(limit=10)
    Scene.group(:location).count.sort_by{|k,v| v}.reverse.first(limit).to_h
  end

end

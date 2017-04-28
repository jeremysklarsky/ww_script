class Character < ApplicationRecord
  has_many :lines

  has_many :scene_characters
  has_many :scenes, :through => :scene_characters

  has_many :location_characters
  has_many :locations, :through => :location_characters

  has_many :episode_characters
  has_many :episodes, :through => :episode_characters

  # most lines
  def self.most_lines(limit=10)
    Line.group(:character).count.sort_by{|k,v| v}.reverse.first(limit).to_h
  end

  def self.most_words(limit=10)
    results = {}
    chars = Character.all.sort_by {|c| c.lines.collect{|line| line.text.split.length}.inject(:+)}.reverse.first(limit)
    chars.each {|char| results[char.name] = char.lines.collect{|line| line.text.split.length}.inject(:+)}
    results
  end

  def self.words_per_line(limit=10)

    chars = self.most_lines(25).keys
    results = {}

    chars.each {|c| results[c.name] = c.words_per_line.round(2)}

    pp results.sort_by{|k,v| v}.reverse.first(limit).to_h


  end

  def longest_line
    self.lines.sort_by {|l| l.text.split.length}.reverse.first.text
  end

  def self.find(name)
    self.find_by_name(name)
  end

  def self.least_words_per_line(limit=20)
    chars = self.most_lines(50).keys
    results = {}

    chars.each {|c| results[c.name] = c.words_per_line.round(2)}

    pp results.sort_by{|k,v| v}.first(limit).to_h


  end

  def words_per_line
    self.lines.collect{|l|l.text.split.size}.inject(:+) / self.lines.size.to_f
  end

  def lines_per_episode
    (self.lines.size / self.episodes.size.to_f).round(1)
  end

  def lines_per_location
    self.lines.group(:location).count.sort_by{|k,v| v}.reverse.to_h
  end 

  def scenes_per_location
    self.scenes.group(:location).count.sort_by{|k,v| v}.reverse.to_h
  end

  def top_scene_partner
    results = Hash.new
    Character.where.not(:name => self.name).each do |character|
      results[character.name] = (self.scenes & character.scenes).size
    end
    results.sort_by {|k,v| v}.reverse.first(20).to_h
  end

  def shared_scenes(characters)
    results = Hash.new
    characters.each do |character|
      results[character.name] = (self.scenes & character.scenes).size
    end

    results.sort_by {|k,v| v}.reverse.to_h
  end

  def self.opening_lines
    Episode.all.collect{|e| e.opening_line.character}
      .each_with_object(Hash.new(0)) { |word,counts| counts[word.name] += 1 }
      .sort_by {|k,v| v}
      .reverse
      .first(20)
      .to_h
  end

  def self.closing_lines
    Episode.all.collect{|e| e.closing_line.character}
      .each_with_object(Hash.new(0)) { |word,counts| counts[word.name] += 1 }
      .sort_by {|k,v| v}
      .reverse
      .first(20)
      .to_h
  end

  def lines_per_episode_hash
    hash = self.lines.group(:episode).count
    results = {}
    hash.each do |e, counts|
      results[e[:title]] = counts
    end
    results
  end

  def self.most_gold_medals
    tops = Episode.top_character_per_episode_by_lines
    results = Hash.new(0)
    tops.each do |ep|
      results[ep.last.keys.first.name] += 1
    end

    results.sort_by {|k,v| v}.reverse.to_h
  end

  def self.okays_by_character
    results = Hash.new(0)
    Line.okays.each do |line|
      results[line.character.name] += 1
    end
  end

  def self.average_scene_length_by_pair
    scenes = Scene.select {|s| s.characters.length == 2}

    results = Hash.new {|hsh, key| hsh[key] = [] }

    scenes.each do |scene|
      characters = scene.characters.collect{|c| c.name}.sort.join (" + ")
      results[characters] << scene.word_count
    end

    
    results.each {|pair, scenes| pair[scenes] = scenes.inject(:+) / scenes.length.to_f}
    binding.pry

  end

end

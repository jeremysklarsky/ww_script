class Episode < ApplicationRecord
  belongs_to :season
  has_many :episode_acts
  has_many :acts, :through => :episode_acts

  has_many :episode_locations
  has_many :locations, :through => :episode_locations

  has_many :episode_characters
  has_many :characters, :through => :episode_characters

  has_many :lines

  def scenes
    self.episode_acts.collect {|s| s.scenes}
  end

  def opening_line
    self.lines.first
  end

  def closing_line
    self.lines.last
  end

  def self.lines_per_episode(sort=false)
    results = {}
    self.all.each{|e| results[e[:title]] = e.lines.count}
    sort ? results.sort_by {|h,k| k}.reverse.to_h : results
  end

  def self.words_per_episode(sort=false)
    results = {}
    self.all.each {|e| results[e[:title]] = e.lines.collect{|l| l.text.split.count}.inject(:+)}
    sort ? results.sort_by {|h,k| k}.reverse.to_h : results
  end

  def words_per_line
    (self.lines.collect{|l| l.text.split.count}.inject(:+) / self.lines.count.to_f).round(2)
  end

  def self.words_per_line_by_episode(sort=false)
    results = {}
    self.all.each{|e| results[e[:title]] = e.words_per_line}
    sort ? results.sort_by {|h,k| k}.reverse.to_h : results
  end

  def self.top_character_per_episode_by_lines
    results = {}
    self.all.each do |episode| 
      most_lines = episode.lines.group(:character).count.sort_by{|k,v| v}.reverse.to_h.first
      results[episode.title] = {most_lines.first => most_lines.last}
    end

    results.sort_by { |k,v| v.to_a.first.last}.reverse
    
  end


end

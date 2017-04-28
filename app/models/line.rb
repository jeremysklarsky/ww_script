class Line < ApplicationRecord
  belongs_to :character
  belongs_to :scene
  belongs_to :episode
  belongs_to :location

  def self.average_length
    self.all.collect{|l|l.text.split.size}.inject(:+) / self.count.to_f
  end

  def self.longest_lines(limit=20)
    results = {}
    lines = Line.all.sort_by {|l| l.text.split.length}.reverse.first(limit)
    lines.each do |l|
      results[l] = l.text.split.length
    end

    results
  end

  def contains_okay
    self.text.split.length == 1 && (self.text.match(/^ok/i) || self.text.match(/^okay/i))
  end

  def self.okays
    self.all.select {|l| l.contains_okay}
  end
end

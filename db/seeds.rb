# SEED LIBRARY FUNCTIONS
def is_character_name(string)
  
  # # criteria for a character name
  # 1. all caps
  # 2. doesn't contain word from blacklist
  (string == string.upcase) && (!blacklist.any? {|word| string.include?(word)} || string == "JEAN-PAUL")
end

def blacklist
  ["TEASER", "FADE", "CUT", "ACT", ":", "-", "DISSOLVE", "THE END", "P.M.", "A.M."] 
end


def is_line(set)
  is_character_name(set.first)
end

def is_stage_direction(string)
  string.upcase != string
end

def is_location(set)
  # if !is_character_name(set.first) && set.first == set.first.upcase 
  #   binding.pry
  # end
  true if !is_character_name(set.first) &&
  set.first == set.first.upcase &&
  !scene_types.any? {|type| set.first.include?(type)} &&
  !is_stage_direction(set.first) &&
  set.first[-1] != ":" &&
  set.first[-1] != "-"

end

def is_act_name(string)
  scene_types.any? {|type| string.first.include?(type)} && !string.first.include?("END")
end

def scene_types
  ["ACT", "TEASER"]
end

def clean_scene_name(string)
  if string.include?(':') && string.include?("-")
    string.split(/\:|-/).map(&:strip)[1]
  elsif string.include?(':')  && !string.include?("-")
    string.split(" : ").first
  elsif !string.include?(':') && string.include?("-")
    string.split(" - ").first
  else
    string
  end
    
  # string.split(/\:|-/).map(&:strip)[1]
end

def build_script(body)
  show = Hash.new {|hsh, act| hsh[act] =  Hash.new{|h,k| h[k] = []}}
  characters = body.collect{|line| line.first}.uniq.select{|name| is_character_name(name)}

  current_act = ''
  current_scene = ''
  scene_number = 0
 
  body.each do |set|
    if is_act_name(set)
      current_act = set.first
      scene_number = 0
    elsif is_location(set)
      scene_number += 1
      current_scene = scene_number.to_s + ": " + clean_scene_name(set.first)
    else
      if set.first.include?(" ")
        show[current_act][current_scene] << reconcile_name(set, characters)
      else
        show[current_act][current_scene] << set
      end
    end
  end

  show
end

def clean_name(name)
  if !name
    name = "UNKNOWN"
  end
  # remove stage directions from people's names
  name.include?("[") ? name.split("[").first.strip : name
end

def clean_line(line)
  # remove stage direction from lines
  if line.include?("[")
    line.gsub(/\[.*?\]/, "").strip
  else
    line
  end
end

def reconcile_name(set, characters)

  characters.delete(set.first)
  characters.each do |char| 

    match = characters.find{|c| set.first.split.any? {|cc| c == cc}}

    if match
      set[0] = char
    else 

    end
  end

  set
end

def find_number(arr)
  arr.split(".").last.to_i
end

def find_season(arr)
  Season.find_by(:number => arr.split(".").first.to_i)
end

def find_title(arr)
  arr[1].gsub('"', "").gsub("'", "")
end

def find_act(act)
  Act.find_by(:name => act)
end

def find_act_name(act, episode)
  episode.title + ": " + act
end

def find_or_create_location(scene)
  if scene == ""
    scene = "X: OS"
  end

  Location.find_or_create_by(:name => scene.split(":").map(&:strip).last)
end

def find_or_create_character(line)
  Character.find_or_create_by(name: line.first)
end

# END LIBRARY FUNCTIONS

ACT_TYPES = ["TEASER", "ACT ONE", "ACT TWO", "ACT THREE", "ACT FOUR", "ACT FIVE"]
SEASONS = (1..4).to_a

SEASONS.each do |num| 
  Season.create({number: num})
end

ACT_TYPES.each {|type| Act.create({name: type})}

Dir.foreach( "#{Rails.root}/lib/assets/scripts/") do |f|
  next if f == '.' or f == '..'  

  # split script into array. Each element is scene info, a line, stage or stage direction
  script_array = File.open("#{Rails.root}/lib/assets/scripts/#{f}", 'rb') { |file| file.read }.split("\n\n")

  # split off title info
  # # find location of "teaser"
  teaser_index = script_array.index {|line| line.strip == "TEASER"}
  title_array = script_array[0..teaser_index-1].join.split("\n").map{|entry| entry.strip.chomp}

  # # find location of ending
  end_index = script_array.index{|line| line.include?("The West Wing and all its characters")}
  # # split up lines into array elements
  body_array = script_array[teaser_index..end_index-1]
    .reject {|line| line.match(/^\t/)}
    .collect{|line| line.split("\n")} # split on line breaks
    .reject {|line| line.length == 0} # remove empty lines
    .collect{|line| line.reject{|l| l.length == 0}} # remove additional blank spaces
    .collect{|line| [clean_name(line[0]), clean_line(line[1..-1].join(" "))]} # combine line elements into single element
    .reject {|line| is_stage_direction(line.first)}

  episode_num = script_array[end_index..-1].find{|l| l.include?("Episode")}.split("-").first.strip.split(" ").last

  script = build_script(body_array)
  @episode = Episode.create
  @episode.number = find_number(episode_num)
  @episode.season = find_season(episode_num)
  @episode.title = find_title(title_array)

  script.each do |act, scenes|
    @episode_act = EpisodeAct.create
    @act_type = find_act(act) #
    @episode_act.name = find_act_name(act, @episode)
    @episode_act.act = @act_type #act belongs to act_type
    @episode_act.episode = @episode # show has many acts, through show_acts

    @episode_act.save
    scenes.each do |scene, lines|
      @scene = Scene.create

      @scene.episode_act = @episode_act
      @location = find_or_create_location(scene)
      @scene.location = @location #scene belongs to a location, location has many scenes

      @scene.name = @episode.title + ", " + @act_type.name + " - " + scene
      @scene.save
      @location.save
      @episode_act.save

      lines.each_with_index do |line, index|
        @line = Line.new
        @line.text = line.last
        @character = find_or_create_character(line)

        if index > 0
          previous_character = find_or_create_character(lines[index -1])
          if @character == previous_character
            @line = @character.lines.last
            @line.text += " " + line.last
          end
        end

        # previous_line = Line.all.last

        # if (previous_line.character == @character && previous_line.scene == @scene)
        #   @line = Line.all.last
        #   @line.text += ' ' + line.last
        # end

        @line.character = @character #line belongs to character and to scene. character has many lines through character_lines
        @line.episode = @episode
        @line.location = @location
        @line.scene = @scene

        @episode.characters << @character if !@episode.characters.include?(@character)
        @scene.characters << @character if !@scene.characters.include?(@character) #scene has many characters through scene_characters
        @location.characters << @character if !@location.characters.include?(@character) #location has many characters through location_characters

        @line.save
        @character.save
        @episode.save
        @scene.save
        @location.save
      end
    end
  end
  
  @episode.save
  puts @episode.title
end
# SEASON: has_many episodes
# # has a name

# EPISODE: belongs_to season (season_id)
# # has a title
# # has many episode_acts
# # has many episode_locations

# ACT: has_many episode_acts
#  has a name

# EPISODE_ACT: belongs to act, belongs to episode
#  has a (hybrid) name
#  has many scenes
#  episode_id
#  act_id

# LOCATION
# has name
# has many episode_locations
# has many episodes through episode_locations

# SCENE
#  belongs to a location (location_id)
#  belongs to episode_act
#  belongs to episode through episode_act
#  hybrid name

# LINE
# belongs to character
# belongs scene
# belongs to episode

# CHARACTER
# has many lines
# has many scenes through scene_characters
# has many locations to location_characters
# has many episodes throuhg episode_characters

# JOINS
# scene_characters
# location_characters

# episode_characters
# episode_acts
# episode_locations
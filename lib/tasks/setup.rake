namespace :setup do
  desc "setup seasons and acts"
  task create: :environment do

    ACT_TYPES = ["TEASER", "ACT ONE", "ACT TWO", "ACT THREE", "ACT FOUR"]
    SEASONS = (1..4).to_a

    SEASONS.each do |num| 
      Season.create({number: num})
    end

    ACT_TYPES.each {|type| Act.create({name: type})}
  end

end

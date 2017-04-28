list = ["BARTLET","LEO","JOSH","SAM","TOBY","CHARLIE","C.J.","ABBEY","DONNA","WILL"]

namespace :characters do
  desc "setup seasons and acts"
  task overlap: :environment do

    results = {}

    list.each do |name|
      list_copy = list.clone
      list_copy.delete(name)
      @character = Character.find_by_name(name)
      @chars = list_copy.collect {|n| Character.find_by_name(n)}
      results[name] = @character.shared_scenes(@chars)
    end

    pp results

  end

end

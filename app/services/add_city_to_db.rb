require 'JSON'
puts dir.pwd
locations = JSON.parse(File.read('cities.json'))
locations.each do |location|
  Coord.create(
    city: location["city"],
    state: location["state"],
    latitude: location["latitude"],
    longitude: location["longitude"],
    rank: location["rank"].to_i,
    population: location["population"].to_i
    )
end

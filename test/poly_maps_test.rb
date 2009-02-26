require 'test/unit'

puts "requiring: #{File.dirname(__FILE__)}/../init"
require "#{File.dirname(__FILE__)}/../init"


class TestPoint
	attr_accessor :lat
	attr_accessor :lng
end

class TestRegion1
	def self.name
		"East Coast"
	end
	
	def self.points
		melbourne = TestPoint.new
		melbourne.lat, melbourne.lng = -37.82974510807046, 144.84375
		
		sydney = TestPoint.new
		sydney.lat, sydney.lng = -33.88136130043211, 151.2158203125
		
		townsville = TestPoint.new
		townsville.lat, townsville.lng = -19.240624533388736, 146.79931640625
		
		return [melbourne, sydney, townsville]
	end
end

class TestRegion2
	def self.name
		"West Coast"
	end

	def self.points
		perth = TestPoint.new
		perth.lat, perth.lng = -31.944704615355118, 115.86181640625
		
		kununnara = TestPoint.new
		kununnara.lat, kununnara.lng = -15.76265092664824, 128.78173828125
		
		broome = TestPoint.new
		broome.lat, broome.lng = -17.92856668781325, 122.255859375
		
		return [perth, kununnara, broome]
	end
	
end

class PolyMapsTest < Test::Unit::TestCase

  def test_render
    country_config = YAML.load_file File.join(File.dirname(__FILE__), '/../lib/country_centers_and_zooms.yml')
  	regions = [TestRegion1, TestRegion2]
    poly_map = PolyMaps::Renderer.new("AU", regions, "points", 'alert(\'#{region.name}\')', nil, false)
    assert_not_nil poly_map.js.index("var country_zoom = #{country_config['AU']['google_zoom']};")
  	assert_not_nil poly_map.js.index("map.setCenter(new GLatLng(#{country_config['AU']['center_latitude']}, #{country_config['AU']['center_longitude']}), country_zoom)")
  	assert_not_nil poly_map.js.index("alert('East Coast')")
  	assert_not_nil poly_map.js.index("alert('West Coast')")
  end

end

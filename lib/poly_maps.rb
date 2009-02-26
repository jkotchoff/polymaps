module PolyMaps

	class LegendItem
	  attr_accessor :color, :region
	  def initialize(color, region)
	  	@color = color
	  	@region = region
	  end
	end

	class Renderer
		
		def js
			@map_js
		end
		
		def legend_items
			@legend_items
		end
		
		def library_js
			# Write the neccessary JavaScript library stuff for circles etc.
		  IO.read(File.join(File.dirname(__FILE__), '/poly_maps.js'))
		end
		
		def initialize(country_code, regions, relationship_name, onclick_handler, polygon_limit = nil)
	    unless (country = YAML.load_file(File.join(File.dirname(__FILE__), '/country_centers_and_zooms.yml'))[country_code])
		    puts "Polymaps Unsupported country code: #{country_code}"
		    return nil
	    end
	    
			output = ""
			country_zoom = country['google_zoom']
			@legend_items = []
	
			# Create a country polygon to check that drawn points are not incorrectly geocoded
			output += "var country_points = #{country['borders_polygon']};\n"
	    output += "var pts = [];\n"
	    output += "for (var i = 0; i < country_points.length; i++) {\n"
	    output += "  pts[i] = new GLatLng(country_points[i][0],country_points[i][1]);\n"
	    output += "}\n"
	    output += "var country_polygon = new GPolygon(pts,\"#000000\",1,1,\"#{country['fill_color']}\",0.5,{clickable:false});\n"
			output += "var country_zoom = #{country_zoom};\n"
	    output += "map.setCenter(new GLatLng(#{country['center_latitude']}, #{country['center_longitude']}), country_zoom);\n"
			if country_zoom < 4
				output += "var min_area_sqm = 2000000000;\n"
				output += "var circle_radius = 110000;\n"
			elsif country_zoom < 6
				output += "var min_area_sqm = 1500000000;\n"
				output += "var circle_radius = 50000;\n"
			elsif country_zoom < 9
				output += "var min_area_sqm = 250000000;\n"
				output += "var circle_radius = 7000;\n"
			else
				output += "var min_area_sqm = 1500000;\n"
				output += "var circle_radius = 3000;\n"
			end
	
			# Create an array with point locations for all regions
			output += "var regions = ["
			region_js = []
			regions.each_with_index do |region, index|
				points = eval("region.#{relationship_name}")
				next if points.empty?
				@legend_items << LegendItem.new(nil, region)
				next if polygon_limit and index >= polygon_limit
				points_js = []
				points.each do |point|
					points_js << "[#{point.lat},#{point.lng}]"
				end
				onclick = "null"
	  		unless onclick_handler.nil? or onclick_handler == ""
	  			js = eval("\"#{onclick_handler}\"")
				  onclick = "function() { #{js}; }"
				end
				region_js[region_js.length] =  "[#{onclick},[#{points_js.join(',')}]]"
			end		
			output += region_js.join(",")
			output += "];\n"

			# Save the colors used
			hex_colors	= ['#3399cc','#669900','#9966cc','#ff3300','#ff00ff','#ff9900','#cc99cc','#ffff00']
			color_index = 0
			@legend_items.each_with_index do |legend_item, index|
				legend_item.color = (polygon_limit and index >= polygon_limit)? "" : hex_colors[color_index]
		    color_index = (color_index == hex_colors.length-1)? 0 : color_index + 1
			end
			hex_colors_js = hex_colors.collect{|c| "'#{c}'"}.join(',')
	
			# Use JavaScript to loop through each region and add a polygon to the map
	    output += "var hex_colors = [#{hex_colors_js}];\n"
	    output += "var color_index = 0;\n"
	    output += "for(var i = 0; i < regions.length; i++) {\n"
	    output += "  region = regions[i];\n"
	    output += "  hex_color = hex_colors[color_index]\n"
	    output += "  color_index = (color_index == hex_colors.length-1)? 0 : color_index + 1;\n"
	    output += "  var polygon = null;\n"
	    output += "  var region_bounds = new GLatLngBounds();\n"
	    output += "  var points_js = region[1];\n"
	    output += "  var pts = [];\n"
	    output += "  for (var j = 0; j < points_js.length; j++) {\n"
	    output += "    lat_lng = new GLatLng(points_js[j][0],points_js[j][1]);\n"
	    output += "    if (country_polygon.Contains(lat_lng)) {\n"
	    output += "      pts[pts.length] = lat_lng;\n"
	    output += "      region_bounds.extend(lat_lng);\n"
	    output += "    }\n"
	    output += "  }\n"
	    output += "  var region_polygon = new GPolygon(pts,hex_color,1,1,hex_color,0.5);\n"
	    output += "  if (region_polygon.getArea() < min_area_sqm) {\n"
	    output += "  	 polygon = GPolygon.Circle(region_bounds.getCenter(), circle_radius, hex_color, 1, 1, hex_color, 0.5);\n"
	    output += "	 } else {\n"
	    output += "    polygon = calculateConvexHull(map, pts, hex_color);\n"
	    output += "	 }\n"
	    output += "  GEvent.addListener(polygon, 'mouseover', mouseover_cursor);\n"
	    output += "	 if (region[0] != null) {\n"
	    output += "    GEvent.addListener(polygon, 'click', region[0]);\n"
	    output += "	 }\n"
	    output += "  map.addOverlay(polygon);\n"
	    output += "}\n"
	
			@map_js = output
		end
		
	end
	
end

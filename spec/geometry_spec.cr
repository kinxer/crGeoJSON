require "./spec_helper"

describe Geometry do
  describe "#from_json" do
    it "rejects invalid geometry type" do
      expect_raises(Exception, "Invalid geometry type!") do
        Geometry.from_json %({"type":"Sphere"})
      end
    end

    it "rejects missing type string" do
      expect_raises(Exception, "Type field invalid or missing!") do
        Geometry.from_json %({"kind":"Sphere"})
      end
    end

    it "accepts valid geometry types" do
      geometry_strings = [%({"type":"Point","coordinates":[0,0]}),
                          %({"type":"MultiPoint","coordinates":[[0,0]]}),
                          %({"type":"LineString","coordinates":[[0,0],[0,1]]}),
                          %({"type":"MultiLineString","coordinates":[[[0,0],[0,1]],[[1,0],[0,1]]]}),
                          %({"type":"Polygon","coordinates":[[[0,0],[1,0],[0,1],[0,0]]]}),
                          %({"type":"MultiPolygon","coordinates":[[[[0,0],[0,1],[1,0],[0,0]]]]}),
                          %({"type":"GeometryCollection","geometries":[{"type":"Point","coordinates":[0,0]}]})]

      geometry_strings.each do |json|
        Geometry.from_json json
      end

      it "returns a Point for a point string" do
        result = Geometry.from_json %({"type":"Point","coordinates":[0,0]})

        result.should be_a Point
      end

      it "returns the correct Point for a point string" do
        result = Geometry.from_json %({"type":"Point","coordinates":[10,15]})

        reference = Point.new 10, 15

        result.should eq reference
      end
    end
  end

end

describe Point do
  describe ".new" do
    it "creates a new point with the given coordinates" do
      point = Point.new 10.0, 15.0

      point.lon.should eq 10.0
      point.lat.should eq 15.0
    end

    it "takes integer arguments" do
      point = Point.new 10, 15
    end
  end

  describe "#type" do
    it %(returns "Point") do
      point = Point.new 0, 0

      point.type.should eq "Point"
    end
  end

  describe "#to_json" do
    it "returns accurate geoJSON" do
      point = Point.new 10.0, 15.0

      point.to_json.should eq %({"type":"Point","coordinates":[10.0,15.0]})
    end
  end

  describe "#from_json" do
    it "creates a Point matching the json" do
      result = Point.from_json %({"type":"Point","coordinates":[10.0,15.0]})

      reference = Point.new 10.0, 15.0

      result.should eq reference
    end
  end
end

describe MultiPoint do
  describe ".new" do
    it "creates a new multipoint with the given points" do
      first = Position.new 10.0, 15.0
      second = Position.new 20.0, 25.0

      multipoint = MultiPoint.new first, second

      multipoint[0].should eq Position.new(10.0, 15.0)
      multipoint[1].should eq Position.new(20.0, 25.0)
    end
  end

  describe "#type" do
    it %(returns "MultiPoint") do
      multipoint = MultiPoint.new Position.new(0,0)

      multipoint.type.should eq "MultiPoint"
    end
  end

  describe "#to_json" do
    it "returns accurate geoJSON" do
      first = Position.new 10.0, 15.0
      second = Position.new 20.0, 25.0

      multipoint = MultiPoint.new first, second

      reference_json = %({"type":"MultiPoint","coordinates":[[10.0,15.0],[20.0,25.0]]})

      multipoint.to_json.should eq reference_json
    end
  end

  describe "#from_json" do
    it "creates a MultiPoint matching the json" do
      result = MultiPoint.from_json %({"type":"MultiPoint","coordinates":[[10.0,15.0],[20.0,25.0]]})

      first = Position.new 10.0, 15.0
      second = Position.new 20.0, 25.0
      reference = MultiPoint.new first, second

      result.should eq reference
    end
  end
end

describe LineString do
  describe ".new" do
    it "creates a new linestring with the given points" do
      first = Position.new 10.0, 15.0
      second = Position.new 20.0, 25.0

      linestring = LineString.new first, second

      linestring[0].should eq Position.new(10.0, 15.0)
      linestring[1].should eq Position.new(20.0, 25.0)
    end

    it "rejects fewer than two points" do
      point = Position.new 10.0, 15.0

      expect_raises(Exception, "LineString must have two or more points!") do
        linestring = LineString.new point
      end
    end
  end

  describe "#type" do
    it %(returns "LineString") do
      linestring = LineString.new Position.new(0,0), Position.new(1,0)

      linestring.type.should eq "LineString"
    end
  end

  describe "#to_json" do
    it "returns accurate geoJSON" do
      first = Position.new 10.0, 15.0
      second = Position.new 20.0, 25.0

      linestring = LineString.new first, second

      reference_json = %({"type":"LineString","coordinates":[[10.0,15.0],[20.0,25.0]]})

      linestring.to_json.should eq reference_json
    end
  end

  describe "#from_json" do
    it "creates a LineString matching the json" do
      result = LineString.from_json %({"type":"LineString","coordinates":[[10.0,15.0],[20.0,25.0]]})

      first = Position.new 10.0, 15.0
      second = Position.new 20.0, 25.0
      reference = LineString.new first, second

      result.should eq reference
    end
  end
end

describe MultiLineString do
  describe ".new" do
    it "creates a new multilinestring with the given points" do
      first = Position.new 10.0, 15.0
      second = Position.new 20.0, 25.0

      linestring = LineString.new first, second

      multilinestring = MultiLineString.new linestring

      multilinestring[0].should eq LineString.new(Position.new(10.0,15.0),Position.new(20.0,25.0))
    end
  end

  describe "#type" do
    it %(returns "MultiLineString") do
      linestring = LineString.new Position.new(0,0), Position.new(1,0)

      multilinestring = MultiLineString.new linestring

      multilinestring.type.should eq "MultiLineString"
    end
  end

  describe "#to_json" do
    it "returns accurate geoJSON" do
      first = Position.new 0.0, 0.0
      second = Position.new 0.0, 1.0
      third = Position.new 1.0, 0.0
      fourth = Position.new 0.0, 1.0

      linestring_one = LineString.new first, second
      linestring_two = LineString.new third, fourth

      multilinestring = MultiLineString.new linestring_one, linestring_two

      reference_json = %({"type":"MultiLineString","coordinates":[[[0.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]]]})

      multilinestring.to_json.should eq reference_json
    end
  end

  describe "#from_json" do
    it "creates a MultiLineString matching the json" do
      result = MultiLineString.from_json %({"type":"MultiLineString","coordinates":[[[0.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]]]})

      first = Position.new 0.0, 0.0
      second = Position.new 0.0, 1.0
      third = Position.new 1.0, 0.0
      fourth = Position.new 0.0, 1.0

      linestring_one = LineString.new first, second
      linestring_two = LineString.new third, fourth
      reference = MultiLineString.new linestring_one, linestring_two

      result.should eq reference
    end
  end
end

describe Polygon do
  describe ".new" do
    it "creates a new polygon with the given points" do
      first = Position.new 0,0
      second = Position.new 1,0
      third = Position.new 0,1

      polygon = Polygon.new first, second, third

      polygon.exterior[0].should eq Position.new 0,0
      polygon.exterior[1].should eq Position.new 1,0
      polygon.exterior[2].should eq Position.new 0,1
    end

    it "raises for fewer than three arguments" do
      first = Position.new 0,0
      second = Position.new 1,0

      expect_raises(Exception, "Polygon must have three or more points!") do
        polygon = Polygon.new first, second
      end
    end

    it "creates a new polygon with the given rings" do
      outer_ring = LinearRing.new(Position.new(0,0),Position.new(5,0),Position.new(0,5),Position.new(0,0))
      inner_ring = LinearRing.new(Position.new(1,1),Position.new(1,2),Position.new(2,1),Position.new(1,1))

      polygon = Polygon.new outer_ring, inner_ring

      polygon[0].should eq LinearRing.new(Position.new(0,0),Position.new(5,0),Position.new(0,5),Position.new(0,0))
      polygon[1].should eq LinearRing.new(Position.new(1,1),Position.new(1,2),Position.new(2,1),Position.new(1,1))
    end
  end

  describe "#type" do
    it %(returns "Polygon") do
      polygon = Polygon.new Position.new(0,0), Position.new(1,0), Position.new(0,1)

      polygon.type.should eq "Polygon"
    end
  end

  describe "#to_json" do
    it "returns accurate geoJSON" do
      first = Position.new 0,0
      second = Position.new 1,0
      third = Position.new 0,1

      polygon = Polygon.new first, second, third

      reference_json = %({"type":"Polygon","coordinates":[[[0.0,0.0],[1.0,0.0],[0.0,1.0],[0.0,0.0]]]})

      polygon.to_json.should eq reference_json
    end
  end

  describe "#from_json" do
    it "creates a Polygon matching the json" do
      result = Polygon.from_json %({"type":"Polygon","coordinates":[[[0.0,0.0],[1.0,0.0],[0.0,1.0],[0.0,0.0]]]})

      first = Position.new 0,0
      second = Position.new 1,0
      third = Position.new 0,1

      reference = Polygon.new first, second, third

      result.should eq reference
    end
  end

  describe "#exterior" do
    it "returns the first LinearRing" do
      outer_ring = LinearRing.new(Position.new(0,0),Position.new(5,0),Position.new(0,5),Position.new(0,0))
      inner_ring = LinearRing.new(Position.new(1,1),Position.new(1,2),Position.new(2,1),Position.new(1,1))

      polygon = Polygon.new outer_ring, inner_ring

      polygon.exterior.should eq outer_ring
    end
  end
end

describe MultiPolygon do
  describe ".new" do
    it "creates a new multipolygon with the given polygons" do
      first  = Position.new 0,0
      second = Position.new 1,0
      third  = Position.new 0,1

      polygon_one = Polygon.new first, second, third
      polygon_two = Polygon.new second, first, third

      multipolygon = MultiPolygon.new polygon_one, polygon_two

      multipolygon[0].should eq Polygon.new first, second, third
      multipolygon[1].should eq Polygon.new second, first, third
    end
  end

  describe "#type" do
    it %(returns "MultiPolygon") do
      polygon = Polygon.new Position.new(0,0), Position.new(1,0), Position.new(0,1)

      multipolygon = MultiPolygon.new polygon

      multipolygon.type.should eq "MultiPolygon"
    end
  end

  describe "#to_json" do
    it "returns accurate geoJSON" do
      first  = Polygon.new Position.new(0,0), Position.new(0,1), Position.new(1,0)
      second = Polygon.new Position.new(0,2), Position.new(0,3), Position.new(1,2)

      multipolygon = MultiPolygon.new first, second

      reference_json = %({"type":"MultiPolygon","coordinates":[[[[0.0,0.0],[0.0,1.0],[1.0,0.0],[0.0,0.0]]],[[[0.0,2.0],[0.0,3.0],[1.0,2.0],[0.0,2.0]]]]})

      multipolygon.to_json.should eq reference_json
    end
  end

  describe "#from_json" do
    it "creates a MultiPolygon matching the json" do
      result = MultiPolygon.from_json %({"type":"MultiPolygon","coordinates":[[[[0.0,0.0],[0.0,1.0],[1.0,0.0],[0.0,0.0]]],[[[0.0,2.0],[0.0,3.0],[1.0,2.0],[0.0,2.0]]]]})

      first  = Polygon.new Position.new(0,0), Position.new(0,1), Position.new(1,0)
      second = Polygon.new Position.new(0,2), Position.new(0,3), Position.new(1,2)

      reference = MultiPolygon.new first, second

      result.should eq reference
    end
  end
end

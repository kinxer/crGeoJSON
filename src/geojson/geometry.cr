require "json"
require "./coordinate"

module GeoJSON
  # TODO
  abstract class Geometry < Base
    # TODO
    abstract def coordinates

    # TODO
    def Geometry.new(pull : JSON::PullParser)
      pull.read_begin_object
      while pull.kind != :end_object
        case pull.read_string
        when "type"
          begin
            geometry_type = pull.read_string
          rescue JSON::ParseException
            raise "Type field is not a string!"
          end
        when "coordinates"
          coordinates = CoordinateTree.new pull
        else
          pull.read_next # we currently ignore extra elements
        end
      end
      pull.read_end_object

      if geometry_type.nil?
        raise "Type field missing!"
      end

      if coordinates.nil?
        raise "Coordinates missing!"
      end

      case geometry_type
      when "Point"
        Point.new coordinates
      when "MultiPoint"
        MultiPoint.new coordinates
      when "LineString"
        LineString.new coordinates
      when "MultiLineString"
        MultiLineString.new coordinates
      when "Polygon"
        Polygon.new coordinates
      when "MultiPolygon"
        MultiPolygon.new coordinates
      else
        raise %(Invalid geometry type "#{geometry_type}"!)
      end
    end

    # TODO
    def Geometry.from_json(geometry_json)
      Geometry.new(JSON::PullParser.new geometry_json)
    end

    def_equals_and_hash coordinates, type

    # TODO
    delegate "[]", to: coordinates

    # We need to inherit the Object-default self.from_json because we don't want
    # Geometry subclasses inheriting its special self.from_json method
    macro inherited
      include JSON::Serializable

      def self.from_json(json)
        # yes, this is copied from Object; I'm not sure how else to do it
        parser = JSON::PullParser.new json
        new parser
      end
    end

    # We use a macro to create subclass initializers because any subclass
    # initializer will obscure all superclass initializers
    macro coordinate_type(type, subtype)
      # TODO
      getter coordinates : {{type}}

      # TODO
      def initialize(@coordinates : {{type}})
      end

      # TODO
      def initialize(coordinates : Array({{subtype}}))
        @coordinates = {{type}}.new coordinates
      end

      # TODO
      def initialize(*coordinates : {{subtype}})
        initialize coordinates.to_a
      end

      # TODO
      def initialize(coordinates : CoordinateTree)
        @coordinates = {{type}}.new coordinates
      end
    end
  end

  # TODO
  class Point < Geometry
    getter type : String = "Point"

    coordinate_type Position, subtype: Number

    # TODO
    def initialize(longitude lon, latitude lat, altivation alt = nil)
      @coordinates = Position.new lon, lat, alt
    end

    # TODO
    delegate longitude, latitude, altivation, to: coordinates
  end

  # TODO
  class LineString < Geometry
    getter type : String = "LineString"

    coordinate_type LineStringCoordinates, subtype: Position

    # TODO
    def initialize(*points : Array(Number))
      @coordinates = LineStringCoordinates.new *points
    end
  end

  # TODO
  class Polygon < Geometry
    getter type : String = "Polygon"

    coordinate_type PolyRings, subtype: LinearRing

    # TODO
    def initialize(points : Array(Position))
      begin
        if points.first == points.last
          ring = LinearRing.new points
        else
          ring = LinearRing.new points.push(points.first)
        end
      rescue ex_mal : MalformedCoordinateException
        if ex_mal.message == "LinearRing must have four or more points!"
          raise MalformedCoordinateException.new("Polygon must have three or more points!")
        else
          raise ex_mal
        end
      end

      @coordinates = PolyRings.new ring
    end

    # TODO
    def initialize(*points : Position)
      initialize points.to_a
    end

    # TODO
    def initialize(*points : Array(Number))
      initialize *points.map { |point| Position.new point }
    end

    # TODO
    def exterior
      coordinates[0]
    end
  end

  # TODO
  class GeometryCollection < Base
    include JSON::Serializable

    getter type : String = "GeometryCollection"
    # TODO
    getter geometries : Array(Geometry)

    # TODO
    def initialize(*geometries : Geometry)
      @geometries = Array(Geometry).new.push(*geometries)
    end

    def_equals geometries

    # TODO
    delegate "[]", to: geometries
  end
end

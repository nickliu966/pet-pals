module NearbySearchable
  extend ActiveSupport::Concern

  class_methods do
    def with_coordinates
      where.not(latitude: nil, longitude: nil)
    end

    def near_coordinates(latitude, longitude, radius_miles = nil)
      return all if radius_miles.blank?

      located = with_coordinates

      lat = latitude.to_f
      lng = longitude.to_f
      radius = radius_miles.to_f

      return all if radius <= 0

      lat_delta = radius / 69.0

      lng_denominator = 69.0 * Math.cos(lat * Math::PI / 180.0).abs

      lng_delta =
        if lng_denominator.zero?
          180.0
        else
          radius / lng_denominator
        end

      lng_delta = 180.0 if lng_delta.nan? || lng_delta.infinite? || lng_delta > 180.0

      located
        .where(latitude: (lat - lat_delta)..(lat + lat_delta))
        .where(longitude: (lng - lng_delta)..(lng + lng_delta))
    end
  end
end

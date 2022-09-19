# frozen_string_literal: true

class VehicleSize
  Motorcycle = 1
  Compact = 2
  Large = 3
  Other = 99
end

class Vehicle
  attr_reader :license_plate, :spots_needed, :size, :parking_spots

  def initialize
    @parking_spots = []
    @spots_needed = 0
    @size = nil
    @license_plate = nil
  end

  def get_spots_needed
    @spots_needed
  end

  def get_size
    @size
  end

  def park_in_spot(spot)
    @parking_spots << spot
  end

  def clear_spots
    @parking_spots.each(&:remove_vehicle)
    @parking_spots = []
  end

  def can_fit_in_spot(spot)
    raise NotImplementedError, 'This method should have implemented.'
  end
end

class Motorcycle < Vehicle
  def initialize
    super
    @spots_needed = 1
    @size = VehicleSize::Motorcycle
  end

  def can_fit_in_spot(_spot)
    true
  end
end

class Car < Vehicle
  def initialize
    super
    @spots_needed = 1
    @size = VehicleSize::Compact
  end

  def can_fit_in_spot(spot)
    spot.get_size == VehicleSize::Large || spot.get_size == VehicleSize::Compact
  end
end

class Bus < Vehicle
  def initialize
    super
    @spots_needed = 5
    @size = VehicleSize::Large
  end

  def can_fit_in_spot(spot)
    spot.get_size == VehicleSize::Large
  end
end

class ParkingSpot
  attr_reader :level, :vehicle, :row, :spot_number, :spot_size

  def initialize(lvl, r, n, sz)
    @level = lvl
    @row = r
    @spot_number = n
    @spot_size = sz
    @vehicle = nil
  end

  def is_available
    @vehicle.nil?
  end

  def can_fit_vehicle(vehicle)
    is_available && vehicle.can_fit_in_spot(self)
  end

  def park(vehicle)
    @vehicle = vehicle
    return false unless can_fit_vehicle(vehicle)

    @vehicle.park_in_spot(self)
    true
  end

  def remove_vehicle
    @level.spot_freed
    @vehicle = nil
  end

  def get_row
    @row
  end

  def get_spot_number
    @spot_number
  end

  def get_size
    @spot_size
  end
end

class Level
  attr_reader :spots, :number_spots, :available_spots, :spots_per_row, :floor

  def initialize(flr, num_rows, spots_per_row)
    @floor = flr
    @spots_per_row = spots_per_row
    @number_spots = 0
    @available_spots = 0
    @spots = []

    num_rows.times do |row|
      (0..spots_per_row / 4).each do |_spot|
        sz = VehicleSize::Motorcycle
        @spots << ParkingSpot.new(self, row, @number_spots, sz)
        @number_spots += 1
      end

      (spots_per_row / 4..spots_per_row / 4 * 3).each do |_spot|
        sz = VehicleSize::Compact
        @spots << ParkingSpot.new(self, row, @number_spots, sz)
        @number_spots += 1
      end

      (spots_per_row / 4 * 3..spots_per_row).each do |_spot|
        sz = VehicleSize::Large
        @spots << ParkingSpot.new(self, row, @number_spots, sz)
        @number_spots += 1
      end
    end

    @available_spots = @number_spots
  end

  def park_vehicle(vehicle)
    return false if get_available_spots < vehicle.get_spots_needed

    spot_num = find_available_spots(vehicle)

    return false if spot_num.negative?

    park_starting_at_spot(spot_num, vehicle)
  end

  def find_available_spots(vehicle)
    spots_needed = vehicle.get_spots_needed
    last_row = -1
    spots_found = 0

    @spots.each_with_index do |spot, i|
      if last_row != spot.get_row
        spots_found = 0
        last_row = spot.get_row
      end

      if spot.can_fit_vehicle(vehicle)
        spots_found += 1
      else
        spots_found = 0
      end

      return i - (spots_needed - 1) if spots_found == spots_needed
    end

    -1
  end

  def park_starting_at_spot(spot_num, vehicle)
    vehicle.clear_spots
    success = true

    (spot_num..spot_num + vehicle.get_spots_needed).each do |i|
      success &&= @spots[i].park(vehicle)
    end

    @available_spots -= vehicle.get_spots_needed
    success
  end

  def spot_freed
    @available_spots += 1
  end

  def get_available_spots
    @available_spots
  end
end

class ParkingLot
  attr_reader :levels

  def initialize(n, num_rows, spots_per_row)
    @levels = []
    n.times do |i|
      @levels << Level.new(i, num_rows, spots_per_row)
    end
  end

  def park_vehicle(vehicle)
    @levels.each do |level|
      return true if level.park_vehicle(vehicle)
    end
    false
  end

  def unpark_vehicle(vehicle)
    vehicle.clear_spots
  end
end

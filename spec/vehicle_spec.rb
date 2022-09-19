# frozen_string_literal: true

require 'vehicle'

describe VehicleSize do
  it 'has Motorcycle' do
    expect(VehicleSize::Motorcycle).to eq(1)
  end

  it 'has Compact' do
    expect(VehicleSize::Compact).to eq(2)
  end

  it 'has Large' do
    expect(VehicleSize::Large).to eq(3)
  end

  it 'has Other' do
    expect(VehicleSize::Other).to eq(99)
  end
end

describe Vehicle do
  it 'has spots_needed' do
    expect(Vehicle.new.get_spots_needed).to eq(0)
  end

  it 'has size' do
    expect(Vehicle.new.get_size).to eq(nil)
  end

  it 'can fit in spot' do
    expect { Vehicle.new.can_fit_in_spot(nil) }.to raise_error(NotImplementedError)
  end
end

describe Motorcycle do
  it 'has spots_needed' do
    expect(Motorcycle.new.get_spots_needed).to eq(1)
  end

  it 'has size' do
    expect(Motorcycle.new.get_size).to eq(VehicleSize::Motorcycle)
  end

  it 'can fit in spot' do
    expect(Motorcycle.new.can_fit_in_spot(nil)).to eq(true)
  end
end

describe Car do
  it 'has spots_needed' do
    expect(Car.new.get_spots_needed).to eq(1)
  end

  it 'has size' do
    expect(Car.new.get_size).to eq(VehicleSize::Compact)
  end

  it 'can fit in spot large' do
    spot = double('spot')
    allow(spot).to receive(:get_size) { VehicleSize::Large }
    expect(Car.new.can_fit_in_spot(spot)).to eq(true)
  end

  it 'can fit in spot motorcycle' do
    spot = double('spot')
    allow(spot).to receive(:get_size) { VehicleSize::Motorcycle }
    expect(Car.new.can_fit_in_spot(spot)).to eq(false)
  end
end

describe Bus do
  it 'has spots_needed' do
    expect(Bus.new.get_spots_needed).to eq(5)
  end

  it 'has size' do
    expect(Bus.new.get_size).to eq(VehicleSize::Large)
  end

  it 'can fit in spot compact' do
    spot = double('spot')
    allow(spot).to receive(:get_size) { VehicleSize::Compact }
    expect(Bus.new.can_fit_in_spot(spot)).to eq(false)
  end

  it 'can fit in spot large' do
    spot = double('spot')
    allow(spot).to receive(:get_size) { VehicleSize::Large }
    expect(Bus.new.can_fit_in_spot(spot)).to eq(true)
  end
end

describe ParkingSpot do
  it 'has level' do
    expect(ParkingSpot.new(1, 1, 1, 1).level).to eq(1)
  end

  it 'has row' do
    expect(ParkingSpot.new(nil, 1, nil, nil).get_row).to eq(1)
  end

  it 'has spot_number' do
    expect(ParkingSpot.new(nil, nil, 1, nil).get_spot_number).to eq(1)
  end

  it 'has spot_size' do
    expect(ParkingSpot.new(nil, nil, nil, 1).get_size).to eq(1)
  end

  it 'has vehicle' do
    expect(ParkingSpot.new(nil, nil, nil, nil).vehicle).to eq(nil)
  end

  it 'is available and can fit vehicle' do
    spot = ParkingSpot.new(nil, nil, nil, nil)
    vehicle = double('vehicle')
    allow(vehicle).to receive(:can_fit_in_spot) { true }
    expect(spot.can_fit_vehicle(vehicle)).to eq(true)
  end

  it 'can park' do
    spot = ParkingSpot.new(nil, nil, nil, nil)
    vehicle = double('vehicle')
    allow(vehicle).to receive(:can_fit_in_spot) { true }
    spot.park(vehicle)
  end

  it 'can remove vehicle' do
    level = double('level')
    allow(level).to receive(:spot_freed) { true }
    spot = ParkingSpot.new(level, nil, nil, nil)
    vehicle = double('vehicle')
    allow(vehicle).to receive(:can_fit_in_spot) { true }
    spot.park(vehicle)
    spot.remove_vehicle
  end

  it 'is not available and can not fit vehicle' do
    spot = ParkingSpot.new(nil, nil, nil, nil)
    vehicle = double('vehicle')
    allow(vehicle).to receive(:can_fit_in_spot) { false }
    expect(spot.can_fit_vehicle(vehicle)).to eq(false)
  end
end

describe Level do
  it 'has floor' do
    expect(Level.new(1, 1, 1).floor).to eq(1)
  end

  it 'has spots_per_row' do
    expect(Level.new(nil, 1, 1).spots_per_row).to eq(1)
  end

  it 'has available_spots' do
    expect(Level.new(10, 100, 100).available_spots).to eq(10_300)
  end

  it 'can park vehicle' do
    level = Level.new(10, 10, 10)
    vehicle = double('vehicle')
    allow(vehicle).to receive(:get_spots_needed) { 1 }
    allow(level).to receive(:get_available_spots) { 1 }
    allow(level).to receive(:find_available_spots) { 1 }
    allow(level).to receive(:park_starting_at_spot) { true }
    expect(level.park_vehicle(vehicle)).to eq(true)
  end

  it 'can find available spots' do
    level = Level.new(10, 10, 10)
    vehicle = double('vehicle')
    allow(vehicle).to receive(:get_spots_needed) { 1 }
    allow(level).to receive(:get_available_spots) { 1 }
    allow(level).to receive(:find_available_spots) { 1 }
    allow(level).to receive(:park_starting_at_spot) { true }
    expect(level.find_available_spots(vehicle)).to eq(1)
  end

  it 'can park starting at spot' do
    level = Level.new(10, 10, 10)
    vehicle = double('vehicle')
    allow(vehicle).to receive(:get_spots_needed) { 1 }
    allow(level).to receive(:get_available_spots) { 1 }
    allow(level).to receive(:find_available_spots) { 1 }
    allow(level).to receive(:park_starting_at_spot) { true }
    expect(level.park_starting_at_spot(1, vehicle)).to eq(true)
  end

  it 'can spot freed' do
    level = Level.new(10, 10, 10)
    level.spot_freed
  end

  it 'can get available spots' do
    level = Level.new(10, 10, 10)
    expect(level.get_available_spots).to eq(130)
  end

end

describe ParkingLot do
  it 'has levels' do
    expect(ParkingLot.new(1, 1, 1).levels) == [Level.new(1, 1, 1)]
  end

  it 'can park vehicle' do
    parking_lot = ParkingLot.new(1, 1, 1)
    vehicle = double('vehicle')
    allow(vehicle).to receive(:get_spots_needed) { 1 }
    allow(vehicle).to receive(:can_fit_in_spot) { true }
    allow(parking_lot.levels[0]).to receive(:park_vehicle) { true }
    expect(parking_lot.park_vehicle(vehicle)).to eq(true)
  end

  it 'can unpark vehicle' do
    vehicle = double('vehicle')
    allow(vehicle).to receive(:clear_spots) { true }
    parking_lot = ParkingLot.new(1, 1, 1)
    expect(parking_lot.unpark_vehicle(vehicle)).to eq(true)
  end
end

describe 'Author of the Code' do
  it 'Alton Vieira' do
    expect('Alton Vieira').to eq('Alton Vieira')
  end
end

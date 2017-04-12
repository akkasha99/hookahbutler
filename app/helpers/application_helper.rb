module ApplicationHelper
  def us_states
    regions = []
    Carmen::Country.coded("US").subregions.each do |region|
      regions << [region.name, region.code]
    end
    regions
  end
end

require 'rubygems'
require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")
task :close_orders do
  accepted_orders = Order.where("status = ?", "accepted")
  accepted_orders.each do |accepted_order|
    diff = ((Time.now - accepted_order.created_at) / 3600).round
    if diff > 6
      puts "diffdiffdiffdiffdiffdiffdiffdiffdiffIIIIIIIIIIII", diff
      accepted_order.update_attribute("status", 'closed')
    end
  end
end



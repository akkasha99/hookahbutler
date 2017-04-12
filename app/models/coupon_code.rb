class CouponCode < ActiveRecord::Base
  belongs_to :promotion_code_user, :class_name => 'User'
  belongs_to :user

  def get_status(coupon_code)
    status = "Open"
    @flag = true
    if Time.now >= coupon_code.valid_from and  Time.now <= coupon_code.valid_to
    else
      @flag = false
    end
    @count = CouponCodeUser.where(:coupon_code_id => coupon_code.id).size
    if coupon_code.per_coupon > 0 && @count >= coupon_code.per_coupon
      @flag = false
    end
    if @flag == false
      status = "Expired"
    else
      status = "Open"
    end
    return status
  end


end

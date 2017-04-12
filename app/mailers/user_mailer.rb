class UserMailer < ActionMailer::Base

  default :from => "support@hookahbutler.com"

  def welcome (current_user)
    @resource = current_user
    mail(:to => @resource.email,
         :subject => "Thank you for Registering!")

  end

  def support_request(description, user, host, protocol)
    @description = description
    @user = user
    mail(:to => "support@hookahbutler.com",
         :subject => "Support Request")
  end

  def order_mail(order, user, host, protocol)
    @order = order
    @user = user
    mail(:to => user.email,
         :subject => "Thank You for your order")
  end

  def cancel_order_mail(order, user, reason, host, protocol)
    @order = order
    @reason = reason
    @user = user
    mail(:to => user.email,
         :subject => "Your Order Cancel")
  end

end

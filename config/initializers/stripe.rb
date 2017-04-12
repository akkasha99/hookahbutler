Rails.configuration.stripe = {
    :publishable_key => ENV['PUBLISHABLE_KEY'],
    :secret_key => ENV['SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

#test keys of hookahbutler account
#PUBLISHABLE_KEY=pk_test_mXsIy1GtII8nLF9pfvG1nsaW SECRET_KEY=sk_test_lpSn8SNevPxo1am1DmG8nE2g rails s

#live keys of hookahbutler account
#PUBLISHABLE_KEY=pk_live_SIsyJEjYh9BNCyBcrBqQC36g SECRET_KEY=sk_live_aLUhej4ZHs1Qr4xlrq4BGu33 rails s

# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_l_session',
  :secret      => '4f7716244c1d2aeec99d10d3e601d17c6be566eb5d9d2d8c85a711849efe7c8232259b08c04fc7c8ab5a9dd48a6f4c0d2d85101a9014afb9cbdb55e1accb09ce'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

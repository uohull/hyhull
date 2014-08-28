require "resque/server"
# This is used to add very simple authorisation to the Sinatra Resque::Server - Only admins should be able to view the queue
module Hyhull
  module Resque
    class AuthorisedResqueServer < ::Resque::Server
      before do
        redirect "/" unless env['warden'].user.groups.include? "admin"
      end
    end
  end
end
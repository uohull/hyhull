# spec/controllers/catalog_controller_spec.rb
require 'spec_helper'

describe ApplicationController do

  controller do
    before_filter :require_login, only: [:index] 
    def index
    end
  end

  # Test require_login functionality
  describe "require_login" do
    it "adds support for using login=true url parameter to force redirect to login page" do
      get :index, { login: "true" }
      expect(response).to be_redirect 
      expect(response).to redirect_to(user_session_path)
    end
  end

end
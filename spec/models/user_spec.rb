require 'spec_helper'

# User class has been extended for use within Hyhull.  
describe User do
  context "Devise modules" do

    describe "trackable" do
       it "should be included" do
         subject.class.ancestors.should include Devise::Models::Trackable
       end
     end
  end
end

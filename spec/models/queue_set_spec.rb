# encoding: utf-8
# spec/models/queue_set_spec.rb

require 'spec_helper'

describe QueueSet do
  
  context "class" do
    before(:each) do
      # Create a new queue_set object for the tests... 
      @queue_set = QueueSet.new
    end

    it "should inherit from the StructuralSet class" do
      @queue_set.is_a? StructuralSet
    end
  end

end
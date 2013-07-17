# app/controllers/dataset_controller.rb
class DatasetsController < ApplicationController

  include Hyhull::Controller::ControllerBehaviour 

  def new
    @dataset = Dataset.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dataset }
    end

  end

  def create 
    @dataset = Dataset.new(params[:dataset])
    @dataset.apply_depositor_metadata(current_user.username, current_user.email)

    respond_to do |format|
      if @dataset.save
        format.html { redirect_to(edit_dataset_path(@dataset), :notice => 'Dataset was successfully created.') }
        format.json { render :json => @dataset, :status => :created, :location => @dataset }
      else
        format.html {
          #flash[:error] = "There has been problems creating this resource"
          render :action => "new"
        }
        format.json { render :json => @dataset.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @dataset = Dataset.find(params[:id])
  end

  def edit
    @dataset = Dataset.find(params[:id])
  end

  def update
    @dataset = Dataset.find(params[:id])

    @dataset.update_attributes(params[:dataset])

    respond_to do |format|
      if @dataset.save
        format.html { redirect_to(edit_dataset_path(@dataset), :notice => 'Dataset was successfully updated.') }
        format.json { render :json => @dataset, :status => :created, :location => @dataset }
      else
        format.html { render "edit" }
      end
    end

  end


end
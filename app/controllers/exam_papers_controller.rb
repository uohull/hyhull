# app/controllers/exam_papers_controller.rb
class ExamPapersController < ApplicationController

  include Hyhull::Controller::ControllerBehaviour 

  def new
    @exam_paper = ExamPaper.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @exam_paper }
    end

  end

  def create 
    @exam_paper = ExamPaper.new(params[:exam_paper])
    @exam_paper.apply_depositor_metadata(current_user.username, current_user.email)

    respond_to do |format|
      if @exam_paper.save
        format.html { redirect_to(edit_exam_paper_path(@exam_paper), :notice => 'Exam paper was successfully created.') }
        format.json { render :json => @exam_paper, :status => :created, :location => @exam_paper }
      else
        format.html {
          #flash[:error] = "There has been problems creating this resource"
          render :action => "new"
        }
        format.json { render :json => @exam_paper.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @exam_paper = ExamPaper.find(params[:id])
  end

  def edit
    @exam_paper = ExamPaper.find(params[:id])
  end

  def update
    @exam_paper = ExamPaper.find(params[:id])

    @exam_paper.update_attributes(params[:exam_paper])

    respond_to do |format|
      if @exam_paper.save
        format.html { redirect_to(edit_exam_paper_path(@exam_paper), :notice => 'Exam paper was successfully updated.') }
        format.json { render :json => @exam_paper, :status => :created, :location => @exam_paper }
      else
        format.html { render "edit" }
      end
    end

  end


end
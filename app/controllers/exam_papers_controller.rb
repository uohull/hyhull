# app/controllers/exam_papers_controller.rb
class ExamPapersController < ApplicationController
  include Hyhull::Controller::ControllerBehaviour 
 
  before_filter :apply_date_params, only: :new

  def initial_step
    @exam_paper = ExamPaper.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @exam_paper }
    end
  end

  def new
    @exam_paper = ExamPaper.new(params[:exam_paper])

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
        format.html { redirect_to(edit_exam_paper_path(@exam_paper), :notice => "Exam paper was successfully created as #{@exam_paper.id}") }
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

  def destroy
    exam_paper = ExamPaper.find(params[:id])
    exam_paper.delete

    respond_to do |format|
      format.html { redirect_to(root_url, :notice => "Examination paper #{params[:id]} was successfully deleted.") }
      format.json { render :json => exam_paper, :status => :deleted }
    end

  end

  private

  # This method will take the date params populated from the intial_step form
  # combine yyyy-mm and add them to the params[:exam_paper] 'date_issed' field
  def apply_date_params
    if (params["date"] && (params["date"]["month"] && params["date"]["year"]))
      month = params["date"]["month"]
      year = params["date"]["year"]
      params[:exam_paper][:date_issued] = "#{year}-#{month}"
    end
  end

end
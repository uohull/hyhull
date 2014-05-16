# app/controllers/journal_articles_controller.rb
class JournalArticlesController < ApplicationController
  include Hyhull::Controller::ControllerBehaviour 
 
  def new
    @journal_article = JournalArticle.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @journal_article }
    end

  end

  def create     
    # If admin user, on create the namespace of the object will be defined by the pid_namespace attribute 
    if current_user.admin?
      @journal_article =  JournalArticle.new(params[:journal_article].merge({ namespace: params[:journal_article][:pid_namespace]}))
    else
      # Other users cannot define the pidnamespace therefore Fedora default will be used (we ensure it isn't set by using nil)...
      @journal_article = JournalArticle.new(params[:journal_article].merge({ namespace: nil}))
    end

    @journal_article.apply_depositor_metadata(current_user.username, current_user.email)

    respond_to do |format|
      if @journal_article.save
        format.html { redirect_to(edit_journal_article_path(@journal_article), :notice => "Journal Article was successfully created as #{@journal_article.id}") }
        format.json { render :json => @journal_article, :status => :created, :location => @journal_article }
      else
        format.html {
          #flash[:error] = "There has been problems creating this resource"
          render :action => "new"
        }
        format.json { render :json => @journal_article.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @journal_article = JournalArticle.find(params[:id])
  end

  def edit
    @journal_article = JournalArticle.find(params[:id])
  end

  def update
    @journal_article = JournalArticle.find(params[:id])

    @journal_article.update_attributes(params[:journal_article])

    respond_to do |format|
      if @journal_article.save
        format.html { redirect_to(edit_journal_article_path(@journal_article), :notice => 'Journal Article was successfully updated.') }
        format.json { render :json => @journal_article, :status => :created, :location => @journal_article }
      else
        format.html { render "edit" }
      end
    end
  end

  def destroy
    journal_article = JournalArticle.find(params[:id])
    journal_article.delete

    respond_to do |format|
      format.html { redirect_to(root_url, :notice => "Journal article #{params[:id]} was successfully deleted.") }
      format.json { render :json => journal_article, :status => :deleted }
    end

  end



end
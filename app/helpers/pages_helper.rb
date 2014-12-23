module PagesHelper

 # Returns a Link to the Examination papers through Login, if not a current_user, and a standard link if already signed in as staff/student 
  def exam_papers_link
    if current_user.nil?        
        link_to("Examination papers (Click to sign in)", "resources?f[genre_sim][]=Examination+paper&login=true")
    else
       link_to("Examination papers", "resources?f[genre_sim][]=Examination+paper") if staff_or_student_user?
    end
  end

end

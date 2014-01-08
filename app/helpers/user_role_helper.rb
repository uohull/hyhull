module UserRoleHelper

  #########################################################
  #                                                       #
  # UserRoleHelper                                        #
  # * Provides user/session helper methods                #
  #                                                       #
  #########################################################

  def staff_or_student_user?
    staff_or_student = false
    if has_user_authentication_provider? && current_user       
      staff_or_student = user_member_of_group?(current_user, "student") || user_member_of_group?(current_user, "staff")
    end
  end

  def contentAccessTeam_user? 
    contentAccessTeam_user = false
    if has_user_authentication_provider? && current_user       
      contentAccessTeam_user = user_member_of_group?(current_user, "contentAccessTeam")
    end
  end

  def admin_user? 
    admin_user = false
    if has_user_authentication_provider? && current_user       
      admin_user = user_member_of_group?(current_user, "admin")
    end
  end

  private 

  def user_member_of_group?(user, group)
    return user.groups.include?(group)
  end

end
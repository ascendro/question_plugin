class QuestionIssueHooks < Redmine::Hook::ViewListener
  
  # Applies the question class to each journal div if they are questions
  def view_issues_history_journal_bottom(context = { })
    o = ''
    if context[:journal] && context[:journal].question
      o += "<script type='text/javascript'>$('change-#{context[:journal].id}').addClassName('question');</script>"
    end
    return o
  end
  
  def view_issues_edit_notes_bottom(context = { })
    f = context[:form]
    @issue = context[:issue]
    o = ''
    o << content_tag(:p, 
                     "<label>#{l(:field_question_assign_to)}</label>" + 
                     select(:note,
                            :question_assigned_to,
                            [["Anyone", :anyone]] + (@issue.assignable_users.collect {|m| [m.name, m.id]}),
                            :include_blank => true))
    return o
  end
  
  def controller_issues_edit_before_save(context = { })
    params = context[:params]
    journal = context[:journal]
    if params[:note] && !params[:note][:question_assigned_to].blank?
      if journal.question
        # Update
        # TODO:
      else
        # New
        journal.question = Question.new(
                                        :author => User.current,
                                        :issue => journal.issue
                                        )
        if params[:note][:question_assigned_to] != 'anyone'
          # Assigned to a specific user
          assign_question_to_user(journal, User.find(params[:note][:question_assigned_to].to_i))
        end
      end
    end
    
    return ''
  end
  
  private
  
  def assign_question_to_user(journal, user)
    journal.question.assigned_to = user
  end
end
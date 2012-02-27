class NoteDecorator < BaseDecorator
  decorates :note

  def as_json(options = {})
    {}.tap do |hash|

      # the parent in the controller, e.g. a contact or deal.  This is here
      # for determining the edit_url, etc.
      hash[:parent]      = h.parent.try(:decorate)

      # This data point is to determine if nodes "belong" on a parent's page,
      # e.g. if a note is edited on a contact page and the attached contact is
      # removed, it needs to disappear.
      #
      # If there's no parent, the note always "belongs".
      hash[:belongs]     = !h.parent || model.note_assignments.map(&:assigned).member?(h.parent)

      hash[:id]          = model.id
      hash[:type]        = model.class.name
      hash[:status]      = model.status
      hash[:url]         = h.polymorphic_url(model)

      hash[:title]       = model.title
      hash[:details]     = h.kramdown(model.details)
      hash[:owner]       = model.owner.decorate
      hash[:assignments] = model.assignments.decorate.as_json(:except => :note)
      hash[:attachments] = model.attachments.decorate.as_json

      edit_args = {}
      
      if h.parent
        edit_args["#{h.parent.class.model_name.element}_id"] = h.parent.id
      end

      hash[:edit_url]   = h.edit_polymorphic_url(model, edit_args)
      hash[:created_at] = h.l(model.created_at.to_date)
      hash[:completed]  = model.completed?
    end
  end
end

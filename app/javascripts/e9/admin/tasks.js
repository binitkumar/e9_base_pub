;jQuery(function($) {
  $.e9 = $.e9 || {};

  function toggle_show_more(form, xhr) {
    if (xhr.getResponseHeader('X-Note-Count') <= $('.note', form).length) {
      $('.show-more', form).fadeOut();
    } else {
      $('.show-more', form).fadeIn();
    }
  }

  function notes_success_fn(form) {
    return function(data, status, xhr) {
      if (form.attr('data-paging') == 'true') {
        $.e9.notes.merge(data, form, function() {
          toggle_show_more(form, xhr);
        });
      } else {
        $.e9.notes.complete(data, form);
      }
    }
  }

  function find_note(id) {
    return $('#note_'+id);
  }

  $.extend($.e9, {
    notes: { 
      compile: function(note) {
        var fn = note.type == 'Note' ? 'notes/note' : 'tasks/task';
        return JST[fn](note); 
      },

      replace: function(data) {
        if (data.belongs) {
          find_note(data.id).replaceWith(
            $.e9.notes.compile(data)
          );
        } else {
          $.e9.notes.destroy(data.id);
        }
      },

      add_empty_message: function(form) {
        $('.notes', form).html(
          '<div class="note-empty">'+form.attr('data-empty')+'</div>'
        );
      },

      append: function(data, form, options) {
        options = options || {};

        var $notes = $('.notes', form), fn;

        if (data.length == undefined) { 
          fn = data.completed ? 'prependTo' : 'appendTo';
          data = [data]; 
        } else {
          fn = 'appendTo';
        }

        data = _.reject(data, function(note) {
          return !note.belongs;
        });

        if (!data.length && !$('.note', $notes).length) {
          $.e9.notes.add_empty_message(form);

        } else if (data.length) {
          var html = $.e9.notes.render_html(data);
          $('.note-empty', $notes).remove();

          $(html).hide()[fn]($notes).fadeIn();
        }
      },

      destroy: function(id) {
        find_note(id).fadeOut(function(){$(this).remove()});
      },

      render_html: function(data) {
        // it's important to wrap this in a container so it can be
        // turned into a jQuery element
        return '<div class="note-group">\n' +
                 _.map(data, $.e9.notes.compile).join("\n") +
               '</div>\n';
      },
      
      merge: function(data, form, callback) {

        var existing_ids = $.makeArray($('.note', form));

        existing_ids = $.map(existing_ids, function(el) {
          return $(el).attr('data-id');
        });

        data = _.reject(data, function(note) {
          return _.include(existing_ids, String(note.id));
        });

        $.e9.notes.append(data, form);

        if (callback) {
          callback();
        }
      },

      complete: function(data, form) {
        $('.notes', form).children().remove();
        $.e9.notes.append(data, form);
      }
    }
  });

  $('body.controller-e9-crm-notes form.scope-selects')
    .bind('submit_with_query:before', function(e) {
      // update the $.query with the default limit each scope_select
      var per_page = $('form.notes-form').attr('data-per-page');
      $.query['limit'] = Number(per_page);
    })

    // on success, we need to ...
    .bind('submit_with_query:success', function(e, data, status, xhr) {
      var $form = $('form.notes-form'),
            $h2 = $form.prev('h2');

      // swap the form's class based on active/completed
      if ($.query.active == 'false') {
        $form.addClass('notes-completed').removeClass('notes-active');
        $h2.html($form.attr('data-completed-notes-header'));
      } else {
        $form.removeClass('otes-completed').addClass('notes-active');
        $h2.html($form.attr('data-active-notes-header'));
      }

      // and replace the content of the list
      $.e9.notes.complete(data, $form);

      // and finally show the show-more if applicable
      toggle_show_more($form, xhr);
    })
  ;

  $('form.notes-form .note-status').live('click', function(e) {
    var 
    $this  = $(this),
    $note  = $this.closest('.note'),
    $form  = $this.closest('form'),
    url    = $note.attr('data-url') + '/toggle';

    $.ajax({
      url: url,
      type: 'POST',
      dataType: 'json',
      success: function(data, status, xhr) {
        var form = 'form.notes-' + 
            (data.completed ? 'completed' : 'active');

        $note.fadeOut(function() { 
          $note.remove(); 

          if (!$('.note', $form).length) {
            $.e9.notes.add_empty_message($form);
          }

          $.e9.notes.append(data, $(form));
        });
      }
    });
  });

  $('form.notes-form .show-more').live('click', function() {
    $(this).closest('form').submit();
  });

  $('form.notes-form')
    // this is a really convoluted and probably bug prone method of getting
    // defaults from the form into query params.
    //
    // NOTE it only happens on the initial page load, by design, so further
    // scope select ajax calls will function
    .scope_select_defaults()

    .submit(function(e) {
      e.preventDefault();

      var $form = $(this), params = {}, match;

      if ($form.attr('data-paging') == 'true') {
        params['limit'] = $('.note', $form).length + Number($form.attr('data-per-page'));
      }

      $.extend($.query, params);

      $.ajax({
        url: $form.attr('action'),
        method: $form.attr('method') || 'GET',
        dataType: 'json',
        data: $.query,
        success: notes_success_fn($form)
      });
    })
    .submit()
  ;

});

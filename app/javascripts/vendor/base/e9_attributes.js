;jQuery(function($) {

  /*
   * change the value of the new menu option type link when the scope select
   * changes, e.g. when viewing "Email" menu options, clicking "Add Menu Option"
   * defaults to creating a new email menu option.
   */
  $('body.admin a.new-menu-option').bind('scope-select:change:key', function(e, v) {
    $(this).attr('href', function(i, val) {
      return val.replace(/\[key\]=([^&]*)/, '[key]='+encodeURIComponent(v));
    });
  });


  function _insert_template(template, el) {

    var t = $(template).css('visibility', 'hidden').insertBefore(el);
    t.css('visibility','visible');

    $.event.trigger('e9-attributes:add');
    $.event.trigger('e9-attributes:change');
  }

  window.nested_attributes_child_index = 666;

  /*
   * Adds a new nested assocation.  Depends on the nested association
   * js templates being loaded.
   */
  $('.add-nested-association').live('click', function(e) {
    e.preventDefault();

    var $this     = $(this),
        $fs       = $this.closest('.nested-associations'),
        tmpl_url  = $fs.attr('data-template-url'),
        guests,
        template;

    if (tmpl_url) {
      guests = $fs.find('.nested-association').length - 1;

      $.ajax({
        url: tmpl_url,
        data: 'child_index=' + (window.nested_attributes_child_index++) +
                  '&guests=' + guests,
        dataType: 'json',
        error: function() {
          if (guests == 1) {
            alert("Only 1 guest is permitted for this event");
          } else {
            alert("Only "+guests+" guests are permitted for this event");
          }
        },
        success: function(data) {
          _insert_template(data.template, $this);
        }
      });
    } else {
      // get the template for this attribute type
      try { 
        if (typeof E9A !== 'undefined') {
          template = E9A.js_templates[this.getAttribute('data-association')];

          // sub in the current index and increment it
          template = template.replace(
            new RegExp(E9A.js_templates.start_child_index, 'g'), 
                           ++E9A.js_templates.current_child_index
          );
        } else if (typeof TEMPLATES !== 'undefined') {
          var obj = TEMPLATES[this.getAttribute('data-association')];

          template = obj.template.replace(obj.rx, obj.index++);

          $this = $this.parent();
        }

        // and insert the new template before this link
        _insert_template(template, $this);
      } catch(e) {

      }
    }
  });

  /*
   * Effectively destroys an added nested association, removing the container
   * the association is not persisted, or hiding it and setting the _destroy
   * parameter for the association if it is.
   */
  $('.destroy-nested-association').live('click', function(e) {
    e.preventDefault();

    // grab the parent nested-association and attempt to get its hidden
    // 'destroy' input if it exists.
    var $parent = $(this).closest('.nested-association').hide(),
        $destro = $parent.find('input[id$=__destroy]');

    // If a in input ending in __destroy was found it means that this is a
    // persisted record.  Set that input's value to '1' so it will be destroyed
    // on record commit.
    if ($destro.length) { $destro.val('1'); }

    // otherwise this record was created locally and has not been saved, so
    // simply remove it.
    else { $parent.remove(); }

    $.event.trigger('e9-attributes:remove');
    $.event.trigger('e9-attributes:change');
  });
});

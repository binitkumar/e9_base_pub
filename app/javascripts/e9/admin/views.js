jQuery(function($) {
  /*
   * TODO Much of this code is nearly repeated in widgets.js and should
   * probably eventually be replaced/refactored.
   */

  /*
   * Sortable settings for node lists
   */
  $('ul.nodes').sortable({
    axis: 'y', 
    dropOnEmpty: false, 
    cursor: 'pointer',
    items: 'li',
    handle: '.handle',
    opacity: 0.5,
    update: function(event, ui) {
      refresh_list_order(this);
    }
  }).disableSelection();

  function refresh_list_order(obj) {
    var el = $(obj);
    el.find('li').each(function(index) {
      $(this).find('input').attr('name', function() {
        return this.name.replace(/nodes_attributes\]\[\d+/, "nodes_attributes][" + index );
      });
    });
  }

  /*
   * function to add a node to region's list
   */

  $("select.node-selector").bind($.browser.msie ? "propertychange" : "change", function(e) {
    e.preventDefault();
    var $el       = $(this);
    //var fld      = $('#' + el.attr('data-renderable-select')),
    var region   = $el.closest('.region');

    var len = region.find('li').length;

    var r_id   = $el.val();

    if(r_id != '') { // Assuming "None" option has blank id
      var $sel = $el.children(':selected');
      var r_name = $sel.text();
      var template = node;
      var parent_index = region.children('input').first().attr('name').match(/.*\[(\d+)\]/)[1];

      template = template.replace(/(attributes[_\]\[]+)\d+/g, "$1" + parent_index);
      template = template.replace(/DISPLAY_NAME/g, r_name);
      template = template.replace(/NEW_RECORD/g, len);
      template = template.replace(/RENDERABLE_ID/g, r_id);
      
      region.children('ul').append(template);
      $sel.remove();
    }
  });

  /*
   * function to remove a node from a region's list
   */
  $('a.remove-node').live('click', function(e) {
    e.preventDefault();
    var el = $(this);

    /*
     * The html for each node looks like this:
     *
     * <span class=content>node name</span>
     * <a>the remove link</a>
     * <input type=hidden value=node.id/>
     */

    // grab the id from the input following 
    var id = el.next('input[type=hidden]').val();

    // and add the name from the span previous
    var n  = $.trim(el.prev('.content').html());

    // and add the option back to the select
    el.closest('.region').find('select').append("<option value=\""+id+"\">"+n+"</option>");

    // if a hidden input exists prev to the link it
    // is a _destroy field used by nested_resources.
    // In that case we don't remove the li#node, but
    // instead set it's destroy value to 1 so it will
    // be removed on the controller
    var d_field = el.prev('input[type=hidden]');
    if (d_field.length != 0) {
      d_field.val('1');
      el.parents('.node').hide();
    } else {
      el.parent().remove();
    }
  });
});

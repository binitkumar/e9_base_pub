;jQuery(function($) {
  /*
   * TODO this mostly has been reproduced in widgets, and snippets should
   * probably make use of that code.
   */

  var resource_iname = $('#resource-iname').val();
  var region_template = '\
<li class="ui-state-default">\
  <span class="content">__NAME__</span>\
  <input type="hidden" value="__ID__" name="'+resource_iname+'[region_type_ids][]"/>\
  <a class="remove" title="Remove Region Type" alt="Remove Region Type">Remove</a>\
</li>';

  var $rt_select = $("body.admin select#region_type_ids").bind("change", function() {

    var $sel = $(this).children(':selected'),
          id = $sel.val(),
           n = $sel.text();

    if(!$sel.blank()) {
      $("ul.region-types").append(
        region_template
          .replace(/__NAME__/, n)
          .replace(/__ID__/, id)
      );
      $sel.remove();
    }
  });

  $("body.admin ul.region-types a").live('click', function(e) {
    var $li = $(this).closest('li'),
         id = $li.find('input').val(),
         n  = $li.find('span').text();

    $("<option />").val(id).text(n).appendTo($rt_select);

    $li.remove();
  });
});

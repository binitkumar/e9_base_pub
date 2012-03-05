;jQuery(function() {
  var tag_update = function(tags) {
    $.extend($.query, { 'tagged[]': tags });
    $.submit_with_query();
  }

  //$('body.controller-images.template-index .tags a').live('click', function(e) {
    //e.preventDefault();

    //var tag = $(this).text();

    //if ($.query['tagged[]'] !== [tag]) {
      //tag_update([tag]);
    //} 
  //});

  $('form[action="/image_uploads"] .tag-autocomplete').not('.ui-autocomplete').each(function(i, el) {
    var 
    $input = $(el), 
    $tags = $input.siblings('ul.select'),
    $untagged = $('#untagged-checkbox'),
    get_tags = function() {
      return $.makeArray($('.content', $tags).map(function(i, tag){ return $(tag).text() }));
    },
    disable_tags = function() {
      $tags.html('');
      delete $.query['tagged[]'];
      $input.attr('disabled', 'disabled').attr('placeholder', '');
    },
    enable_tags = function() {
      $input.removeAttr('disabled').attr('placeholder', 'Enter a tag...');
    }

    /* this is in addition to the usual select.list click */
    $('a', $tags).live('click', function(e) {
      e.preventDefault();
      _.defer(function() { tag_update(get_tags()) });
    });

    $('form.scope-selects').bind('e9:scope-selects:clear', function(e) {
      $tags.html('');
    });

    $untagged
      .attr('checked', function() { 
        var checked = $.query['untagged'] == 'true'; 
        if (checked) disable_tags();
        return checked;
      })
      .bind('change', function(e) {
        e.preventDefault();

        var v = $(this).attr('checked');

        if (v) {
          $.query['untagged'] = 'true';
          disable_tags();
        } else {
          delete $.query['untagged'];
          enable_tags();
        }

        $.submit_with_query();
      })
    ;

    $input
      .blur(function() { $(this).val('') })
      .closest('form').bind('submit', function() { return false }).end()
      .autocomplete({
        delay: 350,

        source: function(request, response) {
          var request_str = "term=" + request.term + "&context=Images*";

          if ($.query['tagged[]']) {
            request_str += '&' + $.param({ except: $.query['tagged[]'] });
          }
          
          $.ajax({
            url: "/autocomplete/tags",
            dataType: "json",
            data: request_str,
            success: function(data) {
              var tags = get_tags();

              response(_.select(data, function(obj, i) {
                return !_.include(tags, obj.value);
              }));
            }
          });
        },

        select: function(evt, ui) {
          $input
            .val('').blur()
            .add_select_template(ui.item.value, ui.item.value, $tags);

          tag_update(get_tags());
          return false;
        },

        focus: function(evt, ui) {
          $input.val(ui.item.value);
          return false;
        }
      })

  });
});

;(function($) {
  $.fn.tag_autocomplete = function(options) {
    var 

    cache = {},

    defaultOptions = {
      delay: 350,
      context: null
    },

    init = function(el, options) {
      if (el.data('tag_autocomplete')) return true;

      el.data('tag_autocomplete', options);
    }

    _.defaults(options, defaultOptions);

    return this.each(function(i, el) {

      el = $(el);

      if (init(el, options)) return;

      var 

      $input    = $('input.tag-autocomplete', el),
      $list     = $('ul.tag-select', el),

      $matchall = $('.matchall input', el), 
      has_match = $matchall.length > 0,

      $untagged = $('.untagged input', el), 
      has_untagged = $untagged.length > 0,

      get_tags = function() {
        return $.makeArray($('.content', $list).map(function(i, tag){ return $(tag).text() }));
      },

      disable_tags = function() {
        $list.html('');
        delete $.query['tagged[]'];
        $input.attr('disabled', 'disabled').attr('placeholder', '');
      },

      enable_tags = function() {
        $input.removeAttr('disabled').attr('placeholder', 'Enter a tag...');
      },

      filter = function(data) {
        var tags = get_tags();

        return _.select(data, function(obj, i) {
          return !_.include(tags, obj.value);
        })
      },

      tag_update = function() {
        $.extend($.query, { 'tagged[]': get_tags() });
        update_disabled();
        $.submit_with_query();
      },

      update_disabled = function() {
        if (!has_match) return;

        var disabled = get_tags().length < 2;

        $matchall.attr('disabled', disabled);

        if (disabled) {
          delete $.query['tagged_all'];
          $matchall.attr('checked', false);
        }
      }
      $(update_disabled);

      // init the untagged checkbox if it's present
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
      
      // do a tag update when tags are removed from the list
      $('a', $list).live('click', function(e) {
        e.preventDefault();
        $(this).closest('li').remove();
        _.defer(function() { tag_update(get_tags()) });
      });

      // clear the tag list when scope-selects clear occurs
      $('form.scope-selects').bind('e9:scope-selects:clear', function(e) {
        $list.html('');
      });

      $input
        .blur(function() { $(this).val('') })
        .closest('form').bind('submit', function() { return false }).end()
        .autocomplete({
          delay: options.delay,

          source: function(request, response) {
            var 
            term = request.term,
            context = options.context,
            target = cache;

            if ($.query['tagged[]']) {
              request.except = $.query['tagged[]'];
            }

            if (options.context) {
              request.context = context;
              cache[context] = cache[context] || {};
              target = cache[context];
            }

            if (term in target) {
              response(filter(target[term]));
              return;
            }

            lastXhr = $.getJSON("/autocomplete/tags", request, function(data, status, xhr) {
              target[term] = data;

              if (xhr === lastXhr) {
                response(filter(data));
              }
            });
          },

          select: function(evt, ui) {
            $(this)
              .val('').blur()
              .add_select_template(ui.item.value, ui.item.value, $list);

            tag_update(get_tags());
            return false;
          },

          focus: function(evt, ui) {
            $input.val(ui.item.value);
            return false;
          }
        })
      ;
    })
  }

  $(function() {
    $('form[action="/file_uploads"]').tag_autocomplete({
      context: 'files*',
    })

    $('form[action="/image_uploads"]').tag_autocomplete({
      context: 'images*',
    })

    $('form#contact-filters').tag_autocomplete({
      context: 'users*'
    })
  });
}(jQuery));

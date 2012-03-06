;(function($) {
  var
  /* 
   * tag contexts in acts-as-taggable-on must be legal instance variable names.  
   * Replace spaces with __S__ and dashes with __D__ to solve the issue.  As a side effect
   * it safe to always use the escaped context names as dom ids
   */
  escape_context = function(context) {
    return $.trim(context)
            .toLowerCase()
            .replace(/\s+/g, '__s__')
            .replace(/-/, '__d__')
            .replace(/\*/, '__h__');
  },

  unescape_context = function(context) {
    return $.trim(context)
            .replace(/__s__/g, ' ')
            .replace(/__d__/g, '-')
            .replace(/__h__/g, '*')
            .toLowerCase()
            .replace(/(^|\s)([a-z])/g, function(match, m1, m2) { return m1 + m2.toUpperCase(); });
  };

  $.fn.e9_tags_fieldset = function() {
    var selector = this.selector;

    // some variation of this one is probably better as it leaves a blank field in the form?
    $(".admin-tag")
      .die("click")
      .live("click", function(e) {
        e.preventDefault();
        var $li = $(this).closest('li');
        if (!$li.siblings().length) $li.closest('.context-list').hide();
        $li.remove();
      })
    ;

    return this.each(function(i, el) {
      var $fs = $(el);

      if ($fs.data('e9_tags')) return true;
      $fs.data('e9_tags', true);

      var
      $tag_context = $('[name=tag-context]', $fs), 
      tcv          = $.trim($tag_context.val()),
      tag_template = $('.template', $fs).remove().html(),

      /*
       * If tag-context is blank, default it to Tags. This is important also in that
       * if the tag-context is pre-set, it will considered hidden and not used as
       * a label in the form.
       */
      default_context_value = tcv.length ? tcv : "Tags";

      // hide empty context-lists
      $('.context-list ul', $fs).each(function(ele) {
        var ct = $(this).find('li').length;
        if(ct == 0) $(this).parent().hide();
      });

      var context_cache = {};

      $tag_context
        /*
         * initial setting of context and context blur use this:
         * set context value to default value if context is blank
         */
        .blur(function() {
          $(this).val(function(i, cVal) {
            return $.trim(cVal).length ? cVal : default_context_value
          });
        })

        /*
         * focus does the reverse and set's the value to blank if
         * the context is the default context
         */
        .focus(function() {
          $(this).val(function(i, cVal) {
            return cVal == default_context_value ? "" : cVal;
          });
        })

        .autocomplete({
          delay: 350,
          source: function(request, response) {
            var request_str = "term=" + request.term;
            //if (context_cache.term == request.term && context_cache.content) {
              //response(context_cache.content);
              //return;
            //}
            //if (new RegExp(context_cache.term).test(request.term) && context_cache.content && context_cache.content.length < 13) {
              //response($.ui.autocomplete.filter(context_cache.content, request.term));
              //return;
            //}
            $.ajax({
              url: "/autocomplete/tag-contexts",
              dataType: "json",
              data: request_str,
              success: function(data) {
                //context_cache.term    = request.term;
                //context_cache.content = data;
                response(data);
              }
            });
          },
          focus: function(evt, ui) {
            $tag_context.val(ui.item.label);
            return false;
          }
        })

        // blur on load (set to default if blank)
        .blur()
      ;

      var $addtf = $("[name=add-tag-fld]", $fs), cache = {};

      $addtf.autocomplete({
        delay: 350,
        source: function(request, response) {
          var 
          term        = request.term,
          context     = $tag_context.val(),
          target      = cache;

          if (context != undefined && context != '') {
            request.context = context;
            cache[context] = cache[context] || {};
            target = cache[context];
          }

          if (term in target) {
            response(target[term]);
            return;
          }

          lastXhr = $.getJSON("/autocomplete/tags", request, function(data, status, xhr) {
            target[term] = data;

            if (xhr === lastXhr) {
              response(data);
            }
          });
        },
        focus: function(evt, ui) {
          $addtf.val(ui.item.label);
          return false;
        }
      });


      $(".add-tag-btn", $fs).click(function(evt) {
        evt.preventDefault();
        evt.stopPropagation();

        if (!$.trim($addtf.val()).length) return;

        var 
        regex = /^[a-zA-Z][a-zA-Z0-9- ]*\*?$/,
        message = " must begin with a letter and contain only letters, numbers, spaces, and hyphens",
        tag,
        context,
        u_context;

        tag = $addtf.val();
        if (!tag.match(regex)) {
          alert("Tags" + message);
          return false;
        } 

        context = $.trim($tag_context.val());
        if (!context.match(regex)) {
          alert("Tag contexts" + message);
          return false;
        } 

        context   = unescape_context(context);
        u_context = escape_context(context);

        var list = $("."+u_context+"-context-list ul", $fs);
        if (list.length == 0) {
          var 
          html = '<div class="context-list '+u_context+'-context-list">';

          // if the tag context value was not preset then we use the humanized
          // context value as a label for the separate context lists
          if (!tcv.length) {
            html += '<span>'+context+'</span>';
          }

          html += '<ul></ul></div>';

          $('.tag-contexts', $fs).append(html);
        } 

        list = $("."+u_context+"-context-list ul", $fs);

        if ($.trim(list.find("input[value='"+tag+"']").val()).length) {
          alert("That label exists for this content.  You can't create a duplicate record.");
          return;
        }

        var ele = tag_template;
            ele = ele.replace(/__TAG__/g, tag);
            ele = ele.replace(/__CONTEXT__/g, context);
            ele = ele.replace(/__UCONTEXT__/g, u_context);

        list.append(ele).parent().show();

        try { $.colorbox.resize() } catch(e) {}

        $addtf.val('');
        $tag_context.val('').blur();

        return false;
      });
    });
  }
}(jQuery));

;(function($) {
  $.fn.search_form = function(options) {

    var cache = {}, lastXhr;

    var defaults = {
      delay: 400,

      select: function(evt, ui) {
        $(this)
          .val(ui.item.value)
          .closest('form').submit();

        return false;
      },

      focus: function(evt, ui) {
        $(this)
          .val(ui.item.value);

        return false;
      },

			source: function(request, response) {
				var term = request.term

				if (term in cache) {
					response(cache[term]);
					return;
				}

				lastXhr = $.getJSON("/autocomplete/search", request, function(data, status, xhr) {
					cache[term] = data;
					if (xhr === lastXhr) {
						response(data);
					}
				});
			}
    }

    return this.each(function(i, el) {
      var 
      $form  = $(el),
      $input = $('input[type=text]', el),
      data   = {};

      if ($form.data('search_form')) return;

      options = $.extend({}, defaults, options);
      
      $form.submit(function(e) {
        if ($input.val() == '') e.preventDefault();
      })

      data.options = options;
      data.input   = $input;

      $form.data('search_form', data);

      $input.autocomplete(options);
    })
  }
}(jQuery));

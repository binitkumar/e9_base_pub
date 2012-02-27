;jQuery(function($) {

  $.fn.search_form = function() {
    /*
     * search form
     */
    var $search_form  = $(this),
        $search_query = $('input[type=text]', this);
    
    $search_form.submit(function(e) {
      if ($search_query.val() == '') e.preventDefault();
    })

    /*
     * Search logic
     */
    var search_cache = {};
    $search_query.autocomplete({
      delay: 400,
      source: '/autocomplete/search',
      select: function(evt, ui) {
        $search_query.val(ui.item.value);
        $search_form.submit();
        return false;
      },
      focus: function(evt, ui) {
        $search_query.val(ui.item.value);
        return false;
      }
    }); 
  }
});

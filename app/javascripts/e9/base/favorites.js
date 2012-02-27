;jQuery(function($) {
  $("#favorites a[data-method=delete]").live("ajax:complete", function() {
    var $el = $(this);

    var $sm_link = $("#favorites").find("a.show-more-link");
    if($sm_link.length > 0) {
      var offset = parseInt($sm_link.attr('data-offset')) - 1;
      $sm_link.
        attr("data-offset", offset.toString()).
        attr("href", function(i, val) {
        return val.replace(/offset=\d+/, "offset=" + offset.toString());
      });
    }

    $el.closest(".listing").fadeOut('fast', function() {
      $(this).remove();
    });
  });
});

;jQuery(function($) {
  /*
   * Convenience method for doing a $.fn.load style load through queryYQL
   */
  $.fn.yqlLoad = function(options) {
    if(options.url == undefined) return;

    var $this = $(this);

    options = $.extend({ xpath: '//body' }, options);

    $.queryYQL("select * from html where url='"+options.url+"' and xpath='"+options.xpath+"'", "xml", function(data) {
      if (data.results[0]) $this.html(data.results[0]);
    });
  }
});

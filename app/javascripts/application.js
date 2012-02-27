;jQuery(function($) {
  $.e9 = $.e9 || {};

  /* add 'last' class */
  $('li:last-child').addClass('last');

  /* function to extract the path from a url, ignoring the domain and query */
  function pathify(url) {
    return url && url.match(/(?:https?:\/\/[^\/]*)?([^\\?]*)(?:\\?.*)$/)[1];
  }

  /* 
   * Try to cache the links in the breadcrumb to determine "active" menu links.
   * This will simply be an empty array if no breadcrumb links exist.
   */
  var breadcrumb_links = $.makeArray($('.breadcrumbs a').map(function(i, el) {
    return pathify(el.getAttribute('href'));
  }));
  if (breadcrumb_links[0] == '/') breadcrumb_links.shift();

  /* active & current */
  $('ul.menu li a').each(function(i, el) {
    var href = pathify(el.getAttribute('href'));
    if (!href) return;

    // if the href of the menu IS the pathname, this link is "current" and all 
    // parent links are "active"
    if (href == window.location.pathname) {
      $(el).closest("li").addClass("current").parents("li").addClass("active");

    // otherwise try to check the breadcrumbs for a matching link indicating this 
    // link is a parent of the current page, and thus "active"
    } else if ($.inArray(href, breadcrumb_links) != -1) {
      $(el).closest("li").addClass("active").parents("li").addClass("active");
    }
  });

  /* is this necessary for icons? */
  var _f;(_f=function() {
    $("ul.menu li, a.icon").hoverize();
  })();
  $(document).ajaxComplete(_f);

  $(document)
    .ajaxStart(function() { $('#spinner, .spinner').show() })
    .ajaxStop(function() { $('#spinner, .spinner').hide() })
  ;

  $('#spinner, .spinner')
    .live('ajaxStart', function(){ $(this).show() })
    .live('ajaxStop', function(){ $(this).hide() })
  ;

  /* Open links with "external" rel in new windows */
  $('a[rel*=external], a.new-window').live("click", function() {
    window.open(this.href);
    return false;
  });

  /* Call window.print() for links with the rel "print" */
  $("a[rel=print]").live('click', function() {
    window.print();
    return false;
  });

  /* on load and ajax complete, remove "disabled" from submits - NOTE this will break submits that are SUPPOSED to be disabled */
  $('input[type=submit]').ajaxComplete(function() {
    $(this).removeAttr('disabled');
  }).removeAttr('disabled');

  /*
   * If a password field has rails errors, assume that the next div.field after is the confirmation
   * field and set it to also have errors
   */
  var _f;(_f=function() {
    $('.field_with_errors input[type=password]').closest(".field").next().addClass("field_with_errors");
  })();
  $(document).ajaxComplete(_f);
});

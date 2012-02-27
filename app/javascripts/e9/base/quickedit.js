;jQuery(function($) {

  // quick_edit may be defined before we load this (for setting options)
  $.quick_edit = $.quick_edit || {};

  var noop = function() {}

  $.extend($.quick_edit, {
    targets: $(),
    enabled: false,
    onInit: noop,
    onCbox: noop,

    enableText: 'Enable Quick Edit',
    disableText: 'Disable Quick Edit',

    enableLink: function(el) { 
      $(el).html(function(i, val) {
        return val.replace($.quick_edit.disableText, $.quick_edit.enableText);
      });
    },

    disableLink: function(el) { 
      $(el).html(function(i, val) {
        return val.replace($.quick_edit.enableText, $.quick_edit.disableText);
      });
    },

    default_tooltip_style: {
      classes: 'ui-tooltip-light', tip: { corner: false } 
    }
  });

  /*
   * Merge in class handlers after to allow them to be overridden, or
   * for default class handlers to pre-exist
   */
  $.quick_edit.class_handlers = $.extend({
    'partial': function(el) {
      var npath = el.attr('data-update-node-path');

      return '<a class="qe-ulink"  href="'+ npath +'">Switch</a>';
    },

    'banner': function(el) {
      var npath = el.attr('data-update-node-path'),
          bpath = el.attr('data-renderables-path');

      return '<a class="qe-ulink" href="'+ npath +'">Switch</a>' +
             '<a href="'+ bpath +'">Admin</a>';
    },

    'placeholder': function(el) {
      var epath = el.attr('data-renderable-path') + '/edit';
      return '<a class="qe-qelink" href="'+ epath +'">Edit</a>';
    },

    'default': function(el) {
      var path   = el.attr('data-renderable-path'), 
          npath  = el.attr('data-update-node-path'),
          rpath  = path + '/replace?node_id=' +el.attr('data-node'),
          epath  = path + '/edit';

      return '<a class="qe-qelink" href="'+ epath +'">Edit</a>' +
             '<a class="qe-rlink"  href="'+ rpath +'">Copy</a>' +
             '<a class="qe-ulink"  href="'+ npath +'">Switch</a>' +
             '<a class="qe-elink"  href="'+ epath +'">Admin</a>';
    }
  }, $.quick_edit.class_handlers);


  var

  inited = false,

  container,

  activate = function(targets) {
    (targets || $.quick_edit.targets).each(function(i, el) {
      var $el = $(el), offset = $el.offset();
      $el
        .data('quick_edit')
        .css({ 
          height: $el.height(),
          width:  $el.width(),
          top:    offset.top,
          left:   offset.left
        })
        .show()
      ;
    })
  },

  deactivate = function(targets) {
    (targets || $.quick_edit.targets).each(function(i, el) {
      $(el).data('quick_edit').hide().qtip('hide');
    })
  },

  init_regions = function(targets, force) {
  },

  init_renderables = function(targets, force) {

    $.quick_edit.targets = $.quick_edit.targets.add(targets);

    $.quick_edit.targets.each(function(i, el) {
      var $el = $(el);

      if ($el.data('quick_edit')) {
        if (!force) return true;
        $el.data('quick_edit').remove();
      }

      var $rel = $('<div class="renderable-edit-layer" style="position: absolute" />');

      $el.data('quick_edit', $rel);

      $rel.hide().appendTo(container);

      var
      klass    = $el.attr("data-renderable"),
      handler  = $.quick_edit.class_handlers[klass] || $.quick_edit.class_handlers['default'],
      title    = $el.attr("data-renderable-name"),
      template = 
        '<div class="qe-tooltip">' +
          '<span class="qe-title">'+title+'</span>' +
          '<div>' +
            handler($el) +
          '</div>' +
        '</div>'
      ;

      $rel.qtip({
        content: { text: template },
        hide: { fixed: true, delay: 75 },
        show: { delay: 0 },
        style: $.quick_edit.default_tooltip_style,
        position: { 
          my: 'bottom left',
          at: 'top left',
          viewport: $(window)
        }
      });
    });
  },

  toggle = function(e) {
    if (e) e.preventDefault();

    if($.quick_edit.enabled) {
      $.quick_edit.enableLink($.quick_edit.link);
      deactivate();
    } else {
      $.quick_edit.disableLink($.quick_edit.link);
      activate();
    }

    $.quick_edit.enabled = !$.quick_edit.enabled;
  },

  init = function() {
    inited    = true;
    container = $('<div id="qe-container" />').appendTo('body');

    /* append quick edit link */
    $.quick_edit.link = $('<a id="qe-link">'+$.quick_edit.enableText+'</a>')
      .appendTo('body')
      .click(toggle)
    ;

    /* prepare quick edit tooltip live links */
    $(".qe-qelink, .qe-rlink, .qe-ulink").live('click', function(e) {
      e.preventDefault();
      $.colorbox({
        href: $(this).attr('href'),
        transition: 'none',
        onComplete: $.quick_edit.onCbox
      });
    });

    /* optional callback */
    $.quick_edit.onInit();
  };

  $.fn.quick_edit = function(force) {
    if (!inited) init();

    if ($.quick_edit.enabled) toggle();

    var targets = $(this);

    if (targets.selector.match('region')) {
      init_regions(targets, force);
      init_renderables($('.renderable[data-node]', targets), force);
    } else {
      init_renderables(targets, force);
    }
  }
});

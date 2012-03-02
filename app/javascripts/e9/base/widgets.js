;jQuery(function($) {

  var feed_select_template = '\
<li class="ui-state-default">\
  <span class="content">__NAME__</span>\
  <input type="hidden" value="__ID__" name="__INAME____FIELD__[]"/>\
  <a class="remove" title="Remove" alt="Remove">Remove</a>\
</li>',

  cbox_resize = function() {
    try { $.colorbox.resize() } catch(e) {}
  }

  /*
   * select.list onchange - add an li to the list and remove the option
   */
  $("select.list").live("change", function() {
    var $this = $(this),
        $sel  = $this.children(':selected'),
          id  = $sel.val(),
           n  = $sel.text();

    if(!$sel.blank()) {
      $this.add_select_template(n, id);
      $sel.remove();
    }
  });

  $.fn.add_select_template = function(name, id, el) {
    el = el || this.siblings("ul.select");

    el.append(
      feed_select_template
        .replace(/__NAME__/,  name)
        .replace(/__ID__/,    id)
        .replace(/__FIELD__/, this.attr('data-field'))
        .replace(/__INAME__/, this.attr('data-iname'))
    );

    _.defer(cbox_resize);

    this.attr('data-values', function(i, v) {
      if (!v) v = '';
      v = v.split(',');
      var p = $.inArray(String(id), v);

      if (p == -1) v = v.concat(String(id)); 
      return v.join(',');
    });

    return this;
  }

  /*
   * ul.select remove links - remove the li and add the option to the select
   */ 
  $("ul.select a").live('click', function(e) {
    var $this = $(this),
          $li = $this.closest('li'),
          $ul = $this.closest('ul.select'),
           id = $li.find('input').val(),
            n = $li.find('span').text();

    var $el;
    
    // if the associated element is a list, add the li to it as an option
    if (($el = $ul.siblings('select.list')) && $el.length) {
      $("<option />")
        .val(id)
        .text(n)
        .appendTo($this.closest('ul.select').siblings("select.list"))
      ;

    // if the associated element is an input, remove the li's value to its data array
    } else if (($el = $ul.siblings('input.list')) && $el.length) {
      $el.attr('data-values', function(i, v) {
        if (!v) v = '';
        v = v.split(',');
        var p = $.inArray(id, v);
        if (p != -1) {
          v.splice(p, 1);
        }
        return v.join(',');
      });
    }

    $li.remove();

    _.defer(cbox_resize);
  });

  $('#feed_type').live("change", function() {
    var $this = $(this),
          cid = $this.val(),
          dat = $this.find(':selected').attr('data-value'),
         $set = $(".feed-type");

    if (dat) $set = $set.not(dat);

    $set.each(function(i, el) {
      $(el)
        .hide()
        .find('ul.select a').click().end()
        .find('select').val('').end()
        .find('input[type=text]').val('').end()
        .find('input[type=hidden]').val('').end()
        .find('input[type=checkbox]').attr('checked', false)
      ;
    });

    if (dat) {
      $(dat)
        .find('input[type=hidden]').val('1').end()
        .show();
    }

    _.defer(cbox_resize);
  });

  var _hide_feed_type_fields = function() {
    var ft = $('.feed-type')
      .hide()
      .not(function(i) {
        var $this = $(this);
        if ($this[0].id == 'ft-mixed') {
          return !$this.has('input:checked').length; 
        } else if ($this[0].id == 'ft-event') {
          return !$this.has('input:hidden[value=1]').length;
        } else {
          return !$this.has('ul.select li').length;
        }
      })
      .show()
    ;

    if (ft.length) { 
      $("#feed_type").val(ft[0].id);
      _.defer(cbox_resize);
    }
  }
  _hide_feed_type_fields();
  $(document).ajaxComplete(_hide_feed_type_fields);


  /*
   * feed widget context menu - clear/change the available tags based on context
   */
  $('#widget-tag-context-select').live("change", function() {
    if (window.e9 === undefined) return false;

    var tags = window.e9.tags[$(this).val()];

    // no context means all tags are available, concat them
    if (tags === undefined) {
      tags = [];
      $.each(window.e9.tags, function(k, v) { tags = tags.concat(v) });

      tags.sort(function(x, y){ 
        var a = String(x).toUpperCase(); 
        var b = String(y).toUpperCase(); 
        if (a > b) return 1;
        if (a < b) return -1;
        return 0; 
      }); 

      for (var i=1; i < tags.length;) {
        if (tags[i-1] == tags[i]) tags.splice(i, 1); else i++;
      }
    }

    $('#feed-tags')
      .find('ul.select').html('').end()
      .find('select.list').html(function() {
        return '<option>Add...</option>' + $.map(tags, function(tag, i) { return '<option val="'+tag+'">'+tag+'</option>'; }).join('');
      })
    ;
  });
});

;jQuery(function($) {
  $.fn.load_admin_home_stream = function(url) {
    var $this = $(this);

    $.ajax({
      url: url,
      dataType: 'json',
      success: function(data, status, xhr) {
        var template = 
          '<div class="blog-post">\n' +
          '  <div class="header"><a href="{{permalink}}">{{title}}</a></header>\n' +
          '{{#display_author_info}}  <div class="byline">author info</div>\n{{/display_author_info}}' +
          '</div>\n';

        $this.html($.mustache("{{#blog_posts}}{{>blog_post}}{{/blog_posts}}", data, { blog_post: template }));
      }
    });
  }
});

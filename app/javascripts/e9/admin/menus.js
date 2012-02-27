;jQuery(function($) {

  /*
   * "delegate title to link" field
   */

  $('#soft_link_name').closest('.field').css('display', function() {
    return $('#soft_link_delegate_title_to_link').attr('checked') ? 'none' : 'block';
  });
  
  $('#soft_link_delegate_title_to_link').click(function(e) {
    var $el = $(this), 
        $f  = $('#soft_link_name');

    if($el.attr('checked')) {
      $f.closest('.field').hide();
      $f.val('');
    } else {
      $f.val('');
      $f.closest('.field').show();
      $f.focus();
    }
  });
});

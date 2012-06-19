;(function($) {
  function fileSizeErrorHandler(event, ID, fileObj, errorObj) {
    // fileObj.size is in bits, errorObj.info is the max size in bytes
    var max  = Math.round(parseFloat(errorObj.info) / 1024 * 100) / 100,
        size = Math.round(fileObj.size / 1024000 * 100) / 100;

    alert('Your file is too large ('+size+'MB). The maximum size is '+max+'MB.  Try separating your import into smaller files?');
    return false;
  }

  function completeHandler(event, id, fileObj, response) {
    var 
    message = '',
    object  = $.parseJSON(response), 
    errors  = object.errors,
    info    = object.info;

    if (info) {
      message += info.created + " records were created.\n";
      message += info.updated + " records were updated.\n";
    }

    if (errors) {
      if (errors.missing_code) {
        message += 
          errors.missing_code + " rows were missing a code.\n\n";
      }
      if (errors.incorrect_filetype) {
        message += 
          "The uploaded file wasn't the correct filetype, expected CSV.\n\n";
      }
      if (errors.missing_file) {
        message += 
          "The uploaded file was missing, expected CSV.\n\n";
      }
      if (errors.invalid) {
        message += 
          errors.invalid.length + " rows contained invalid data:\n  " + 
            errors.invalid.join("\n  ");
      }

      if (errors.contact) {
        message += 
          errors.contact.length + " rows contained invalid contact data and were not processed:\n  " + 
            _.map(errors.contact, function(obj) { return "Row "+obj.row+": "+obj.errors[0]; }).join("\n  ") +
            '\n';
      }

      if (errors.user) {
        message += 
          errors.user.length + " rows contained invalid user data and were not processed:\n  " + 
            _.map(errors.user, function(obj) { return "Row "+obj.row+": "+obj.errors[0]; }).join("\n  ") +
            '\n';
      }
    }

    alert(message);
    // window.location = redirect;
  }

  var defaults = {
    scriptData: {}, // REQUIRED (format and xsrf)
    method: "POST",
    hideButton: true,
    wmode: 'transparent',
    uploader: "/swf/uploadify.swf",
    fileDataName: "csv",
    fileExt: "*.csv",
    fileDesc: "(CSV) Comma Separated Values",
    auto: true,
    cancelImg: "/images/buttons/cancel.png",
    onComplete: completeHandler,
    sizeLimit: 1024 * 1000 * 3, // 1mb * 5
    onError: function(event, ID, fileObj, errorObj) {
      if (errorObj.type == 'File Size') 
        return fileSizeErrorHandler.apply(this, arguments);
    }
  }

  var redirect;

  $.fn.csv_upload = function(path, options) {
    redirect = path;
    options = $.extend({}, defaults, options, {
      script: path + '/upload_csv'
    });
    this.uploadify(options);
  }

  /*
   * only necessary if the index uses &.query to filter
   */
  $.fn.csv_export = function() {
    $(this).click(function(e) {
      e.preventDefault();

      _($.query).clean();

      var str = $.param($.query).trim()
        , msg = "You are about to export your entire unfiltered contact list.  This is a potentially long-running operation.  Are you sure?"
        , href = this.getAttribute('href');

      function go(query) {
        query = query || '';
        window.location = href + query;
      }

      if (str.length) {
        go('?'+str);
      } else if (confirm(msg)) {
        go();
      }
    })
  }
}(jQuery));

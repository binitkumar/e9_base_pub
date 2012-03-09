Modernizr.addTest('box-sizing', function() {
  var test = document.createElement('div'),
      root = document.documentElement.appendChild(document.createElement('body'));
      
  test.style.cssText = '-moz-box-sizing:border-box;-webkit-box-sizing:border-box;-ms-box-sizing:border-box;box-sizing:border-box;padding:0 10px;margin:0;border:0;position:absolute;top:0;left:0;width:100px';
  root.appendChild(test);
  
  var ret = test.offsetWidth === 100;
        
  root.removeChild(test);
  document.documentElement.removeChild(root);
  
  return ret;
});

(function (){
// to use hint and bubble, simply create a container with "hint" class and
// <span> with "bubble" class and attrebute "style" - "display: none;", below.
// "hint" - will be the button; "bubble" - container for hint text.

  initHints = function() {
    hintConfig = {
      sensitivity: 3,
      interval: 200,
      timeout: 1000,
      over: function() {
        $('.bubble', this).fadeIn('fast');
      },
      out: function() {
        $('.bubble', this).fadeOut('fast');
      }
    };

    $(".hint").hoverIntent(hintConfig);
    $(".text-hint").hoverIntent(hintConfig);
  };

  $(window).load(function() {
    initHints();
    $(window).on('popstate', initHints);
  });
})();


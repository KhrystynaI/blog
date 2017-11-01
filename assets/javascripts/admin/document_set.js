// this is js to add new button to table tools in DS list, only!
(function () {
  var setupScopesHint = function (html) {
    var ul = document.getElementsByClassName("table_tools_segmented_control")[0];

    var li = document.createElement("li");
    li.setAttribute("class", "hint");

    var a = document.createElement("a");
    a.setAttribute("class", "button table_tools_button");
    a.appendChild(document.createTextNode("?"));

    var span = document.createElement("span");
    span.setAttribute("class", "bubble");
    span.setAttribute("style", "display: none;");
    span.innerHTML = html;

    ul.appendChild(li);
    li.appendChild(a);
    li.appendChild(span);
  };

  $(document).ready(function () {
    if (window.location.pathname != '/admin/document_sets') {
      return;
    }
    var html = 'Active: all active DSs*<br>' +
      'Archived: all archived DSs<br>' +
      'Expired: DSs with expired orders<br>' +
      'Expire Soon: DSs with orders that will expire in leas than 4 months<br>' +
      '*DSs - Document sets';
    setupScopesHint(html);
  });

})();

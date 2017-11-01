//= require active_admin/base
//= require foundation/foundation
//= require foundation/foundation.reveal
//= require fancytree
//= require select2
//= require jsgrid/jsgrid.min
//= require ckeditor/init
//= require admin/jquery.sticky
//= require admin/sortable_questions
//= require plugins.js
//= require bubble
//= require admin/add_universal_questions
//= require admin/new_version_dialog
//= require admin/document_set.js
//= require admin/table_select.js
//= require js_table_filters.js

$(document).ready(function () {
    $(document).foundation();
    $(".datepicker").datepicker({
        dateFormat: "yy/mm/dd"
    });

    $("#active_admin_content .tabs").on( "tabsactivate", function(event, ui) {
        var hash = ui.newPanel.attr('id');
        if(hash) {
            window.location.hash = hash;
        }
    });
});


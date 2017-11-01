// treeData mustn't be empty
var treeData = []

$(function(){
    $(document).foundation();

    //close modal dialog on clik
    $('a.just-close-modal').click(function () {
        $(this).parent().foundation('reveal', 'close');
    });

    //common question ====================================
    jQuery('a.edd-new-question-answers').click(function(event){
        if (jQuery('#q-question').val() !== "") {
            event.preventDefault();
            var newRow = jQuery('<tr id="question">' +
            //'<td class="col col-category"><a href="#">' + jQuery('#q-category').val() + '</a></td>' +
            '<td class="col col-question_text">&nbsp;&nbsp;&nbsp;&nbsp;' + jQuery('#q-question').val() + '</td>' +
            '<td class="col col-answer">' + jQuery('#q-answer').val() + '</td>' +
            '<td class="col col-actions"><a href="#">Edit answer</a>&nbsp;<a href="#">Remove</a></td>' +
            '</tr>');
            jQuery('table').append(newRow);
            jQuery('#q-category').val("");
            jQuery('#q-question').val("");
            jQuery('#q-answer').val("");
            $(".custom-q-container").hide();
        }
        else {
            confirm("Question or Category is empty!!!");
        };
    });

    $('.checkbox-qs').change(function(){
        if($(this).is(":checked")) {
            $(".q_table").hide();
            $(".q-tree").show();
        }
        else {
            $(".q_table").show();
            $(".q-tree").hide();
        };
    });

    //custom questiions clic ==========================
    $('a.custom-q-link').click(function(){
        if($(".custom-q-container").is(':visible')){
            $(".custom-q-container").hide();
        }
        else {
            $(".custom-q-container").show();
        };
    });

    // Attach the fancytree widget to an existing <div id="tree"> element
    // and pass the tree options as an argument to the fancytree() function:
    $("#treetable").fancytree({
        extensions: ["table", "themeroller"],
        checkbox: true,
        source: treeData,
        selectMode: 3,
        activate: function(event, data) {
        },
        lazyLoad: function(event, data) {
            data.result = {url: "ajax-sub2.json"}
        },
        renderColumns: function(event, data) {
            var node = data.node,
                $tdList = $(node.tr).find(">td");
            $tdList.eq(1).text(node.data.answer);
            $tdList.eq(2).text(node.data.customer_question);
        }
    });
});

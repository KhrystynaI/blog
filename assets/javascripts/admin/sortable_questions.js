$(document).ready(function () {
    $("#index_table_question_categories tbody").sortable({
        update: function () {
            $.ajax({
                url: "/admin/question_categories/reorder",
                type: 'patch',
                data: serializePositions(this),
                complete: function () {
                }
            });
        }
    });

    var serializePositions = function (items_container) {
        var result = {};
        $.each($(items_container).find('tr'), function (i, elem) {
            result[$(elem).data('id')] = i;
        });
        return {positions: result};
    };
});

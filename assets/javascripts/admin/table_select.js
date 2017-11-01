$(function(){
    $(".batch_table").tableCheckboxToggler();

    $('a.batch_action').on('confirm:complete', function(){
        var container = $(this).closest('.batch_container');
        var selected = container.find('.collection_selection:checked');
        var path = container.data('path');
        var resource_id = container.data('resource-id');
        var action = $(this).data('action');

        var ids = $.map( selected, function( node, i ) {
            return $(node).closest('tr').data('id');
        });

        $.ajax({
            url: path,
            type: 'post',
            data: { batch_action: action, resource_id: resource_id, ids: ids},
            success: function (data) {
                location.reload();
            }
        });
    });

    //add multiple select / deselect functionality
    $(".toggle_all").click(function () {
        $(this).closest('table').find('td input:checkbox').prop('checked', this.checked);
        toggle_batch_actions(this);
    });

    $(".collection_selection").click(function(){
        toggle_batch_actions(this);
    });

    function toggle_batch_actions(elem){
        var container = $(elem).closest('.batch_container');
        if(container.find('.collection_selection:checked').length > 0){
            container.find('.batch_actions_selector a').removeClass('disabled');
        }else{
            container.find('.batch_actions_selector a').addClass('disabled');
        }
    }

    $(".batch_table").each(function(){
        toggle_batch_actions(this);
    });
});

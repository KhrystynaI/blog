// function for check/uncheck group of checkboxes
function strCheckbox(obj) {
    for (var i = 0; i < str.length; i++) {
        //alert(str[i].id);
        if (str[i].id.id == obj.id) {
            if (obj.checked) {
                for (var j = i - 1; j >= 0; j--){
                    str[j].id.checked = obj.checked;
                }
            }
            else {
                for (var j = i + 1; j < str.length; j++) {
                    str[j].id.checked = obj.checked;
                }
            };
        };
    };
};
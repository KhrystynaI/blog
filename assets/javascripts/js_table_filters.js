/* Examples of use:

 $(".table1").jSTableFilters();

 $(".table2").jSTableFilters({
 columns: [0,1]
 });

 $(".table3").jSTableFilters({
 columns: [1]
 });

 */

$( document ).ready(function() {

    function onlyUnique(value, index, self) {
        return self.indexOf(value) === index;
    };

    function createDropdown(table,column,columnIndex) {

        var s = document.createElement( "select" );
        s.className = "columnFilter";
        s.id = "columnFilter_" + columnIndex.toString();
        column.appendChild(s);

        var o = document.createElement( "option" );
        o.text = "All";
        o.selected = "selected";
        s.appendChild(o);


        var rows = $(table).find( "tr" );
        var options = [];
        rows.each(function(rowIndex, row){
            var cell = $(row).find( "td" )[columnIndex];
            if (cell === undefined) {
                return true;
            };
            options.push($(cell).text());
        });

        options.filter( onlyUnique ).map( function(optionItem) {
            var o = document.createElement("option");
            o.text = optionItem;
            s.appendChild(o);
        });

    };

    function showRow(row, columnIndex, hidenByArray) {
        if ( hidenByArray.length == 0 ) {
            $(row).show();
        } else if ( hidenByArray.length == 1 && hidenByArray.includes(columnIndex) ) {
            $(row).show();
            jQuery.data( row, "hiden_by", []);
        } else if (hidenByArray.includes(columnIndex)) {
            var index = hidenByArray.indexOf(columnIndex);
            if (index > -1) {
                hidenByArray.splice(index, 1);
                jQuery.data( row, "hiden_by", hidenByArray);
            };
        };
    };

    function hideRow(row, columnIndex, hidenByArray) {
        $(row).hide();
        if ( hidenByArray.length == 0 ) {
            jQuery.data( row, "hiden_by", [columnIndex]);
        } else if ( hidenByArray.includes(columnIndex) == false ) {
            hidenByArray.push(columnIndex);
            jQuery.data( row, "hiden_by", hidenByArray);
        };
    };

    jQuery.fn.extend({
        jSTableFilters: function(options) {
            var defaults = {
                columns: []
            };
            options = $.extend(defaults, options);
            return this.each(function() {
                var thisObject = $(this);
                thisObject.addClass("JSTableFilter");

                var columnsArray = thisObject.find( "th" );
                columnsArray.each(function(columnIndex, column){
                    if (options.columns.length > 0) {
                        if (options.columns.includes(columnIndex)) {
                            createDropdown(thisObject,column,columnIndex);
                        };
                    } else {
                        createDropdown(thisObject,column,columnIndex);
                    };
                });
            });
        }
    });

    $("body").on('change', '.columnFilter', function () {
        var options = $(this).find(":selected").text();
        var table = $(this).closest( "table.JSTableFilter" )[0]
        var columnIndex = parseInt(this.id.match(/\d+/)[0]);

        var rows = $(table).find( "tr" );
        rows.each(function(rowIndex, row){
            var cell = $(row).find( "td" )[columnIndex]
            if ( cell == undefined ) {
                return true;
            };

            // initialise hidenByArray
            if ( !Array.isArray(jQuery.data( row, "hiden_by")) ) {
                var hidenByArray = [];
            } else {
                var hidenByArray = jQuery.data( row, "hiden_by");
            };

            if ( options == "All" ) {
                showRow(row, columnIndex, hidenByArray);
            } else if ( $(cell).text() != options ) {
                hideRow(row, columnIndex, hidenByArray);
            } else {
                showRow(row, columnIndex, hidenByArray);
            };
        });
    });
});

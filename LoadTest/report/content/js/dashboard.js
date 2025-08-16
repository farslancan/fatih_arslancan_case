/*
   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
var showControllersOnly = false;
var seriesFilter = "";
var filtersOnlySampleSeries = true;

/*
 * Add header in statistics table to group metrics by category
 * format
 *
 */
function summaryTableHeader(header) {
    var newRow = header.insertRow(-1);
    newRow.className = "tablesorter-no-sort";
    var cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 1;
    cell.innerHTML = "Requests";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 3;
    cell.innerHTML = "Executions";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 7;
    cell.innerHTML = "Response Times (ms)";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 1;
    cell.innerHTML = "Throughput";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 2;
    cell.innerHTML = "Network (KB/sec)";
    newRow.appendChild(cell);
}

/*
 * Populates the table identified by id parameter with the specified data and
 * format
 *
 */
function createTable(table, info, formatter, defaultSorts, seriesIndex, headerCreator) {
    var tableRef = table[0];

    // Create header and populate it with data.titles array
    var header = tableRef.createTHead();

    // Call callback is available
    if(headerCreator) {
        headerCreator(header);
    }

    var newRow = header.insertRow(-1);
    for (var index = 0; index < info.titles.length; index++) {
        var cell = document.createElement('th');
        cell.innerHTML = info.titles[index];
        newRow.appendChild(cell);
    }

    var tBody;

    // Create overall body if defined
    if(info.overall){
        tBody = document.createElement('tbody');
        tBody.className = "tablesorter-no-sort";
        tableRef.appendChild(tBody);
        var newRow = tBody.insertRow(-1);
        var data = info.overall.data;
        for(var index=0;index < data.length; index++){
            var cell = newRow.insertCell(-1);
            cell.innerHTML = formatter ? formatter(index, data[index]): data[index];
        }
    }

    // Create regular body
    tBody = document.createElement('tbody');
    tableRef.appendChild(tBody);

    var regexp;
    if(seriesFilter) {
        regexp = new RegExp(seriesFilter, 'i');
    }
    // Populate body with data.items array
    for(var index=0; index < info.items.length; index++){
        var item = info.items[index];
        if((!regexp || filtersOnlySampleSeries && !info.supportsControllersDiscrimination || regexp.test(item.data[seriesIndex]))
                &&
                (!showControllersOnly || !info.supportsControllersDiscrimination || item.isController)){
            if(item.data.length > 0) {
                var newRow = tBody.insertRow(-1);
                for(var col=0; col < item.data.length; col++){
                    var cell = newRow.insertCell(-1);
                    cell.innerHTML = formatter ? formatter(col, item.data[col]) : item.data[col];
                }
            }
        }
    }

    // Add support of columns sort
    table.tablesorter({sortList : defaultSorts});
}

$(document).ready(function() {

    // Customize table sorter default options
    $.extend( $.tablesorter.defaults, {
        theme: 'blue',
        cssInfoBlock: "tablesorter-no-sort",
        widthFixed: true,
        widgets: ['zebra']
    });

    var data = {"OkPercent": 66.66666666666667, "KoPercent": 33.333333333333336};
    var dataset = [
        {
            "label" : "FAIL",
            "data" : data.KoPercent,
            "color" : "#FF6347"
        },
        {
            "label" : "PASS",
            "data" : data.OkPercent,
            "color" : "#9ACD32"
        }];
    $.plot($("#flot-requests-summary"), dataset, {
        series : {
            pie : {
                show : true,
                radius : 1,
                label : {
                    show : true,
                    radius : 3 / 4,
                    formatter : function(label, series) {
                        return '<div style="font-size:8pt;text-align:center;padding:2px;color:white;">'
                            + label
                            + '<br/>'
                            + Math.round10(series.percent, -2)
                            + '%</div>';
                    },
                    background : {
                        opacity : 0.5,
                        color : '#000'
                    }
                }
            }
        },
        legend : {
            show : true
        }
    });

    // Creates APDEX table
    createTable($("#apdexTable"), {"supportsControllersDiscrimination": true, "overall": {"data": [0.575, 500, 1500, "Total"], "isController": false}, "titles": ["Apdex", "T (Toleration threshold)", "F (Frustration threshold)", "Label"], "items": [{"data": [0.0, 500, 1500, "SearchInvalidEndpoint"], "isController": false}, {"data": [1.0, 500, 1500, "SearchNonExisting"], "isController": false}, {"data": [1.0, 500, 1500, "SearchEmpty"], "isController": false}, {"data": [0.0, 500, 1500, "SearchWithoutHeaders"], "isController": false}, {"data": [1.0, 500, 1500, "SearchEmpty-1"], "isController": false}, {"data": [1.0, 500, 1500, "SearchEmpty-0"], "isController": false}, {"data": [0.0, 500, 1500, "SearchWithInvalidRequestType"], "isController": false}, {"data": [0.5, 500, 1500, "SearchShoePagination"], "isController": false}, {"data": [1.0, 500, 1500, "SearchShoePositive"], "isController": false}, {"data": [0.6, 500, 1500, "SearchShoeSortByPrice"], "isController": false}, {"data": [0.0, 500, 1500, "SearchWithSpecialCharacters"], "isController": false}, {"data": [0.8, 500, 1500, "SearchShoeModelAndNo"], "isController": false}]}, function(index, item){
        switch(index){
            case 0:
                item = item.toFixed(3);
                break;
            case 1:
            case 2:
                item = formatDuration(item);
                break;
        }
        return item;
    }, [[0, 0]], 3);

    // Create statistics table
    createTable($("#statisticsTable"), {"supportsControllersDiscrimination": true, "overall": {"data": ["Total", 60, 20, 33.333333333333336, 197.63333333333335, 11, 710, 69.0, 634.9, 695.85, 710.0, 18.81467544684854, 5079.04521646676, 2.6259088860144244], "isController": false}, "titles": ["Label", "#Samples", "FAIL", "Error %", "Average", "Min", "Max", "Median", "90th pct", "95th pct", "99th pct", "Transactions/s", "Received", "Sent"], "items": [{"data": ["SearchInvalidEndpoint", 5, 5, 100.0, 36.0, 28, 45, 35.0, 45.0, 45.0, 45.0, 5.89622641509434, 654.686118071934, 0.6564158313679246], "isController": false}, {"data": ["SearchNonExisting", 5, 0, 0.0, 173.6, 141, 204, 179.0, 204.0, 204.0, 204.0, 5.370569280343717, 871.4021381578947, 0.7185234291084854], "isController": false}, {"data": ["SearchEmpty", 5, 0, 0.0, 92.8, 67, 121, 100.0, 121.0, 121.0, 121.0, 5.611672278338944, 1325.0889976150393, 1.3426364337822672], "isController": false}, {"data": ["SearchWithoutHeaders", 5, 5, 100.0, 12.8, 11, 16, 12.0, 16.0, 16.0, 16.0, 6.157635467980296, 31.22714939963054, 0.7817310652709359], "isController": false}, {"data": ["SearchEmpty-1", 5, 0, 0.0, 57.2, 37, 80, 61.0, 80.0, 80.0, 80.0, 5.868544600938967, 1378.9761682071596, 0.8023400821596244], "isController": false}, {"data": ["SearchEmpty-0", 5, 0, 0.0, 35.6, 25, 59, 30.0, 59.0, 59.0, 59.0, 5.9171597633136095, 6.824380547337278, 0.6067400147928994], "isController": false}, {"data": ["SearchWithInvalidRequestType", 5, 5, 100.0, 49.2, 43, 60, 48.0, 60.0, 60.0, 60.0, 5.820721769499419, 645.7761113940629, 1.1254911233993015], "isController": false}, {"data": ["SearchShoePagination", 5, 0, 0.0, 677.8, 616, 710, 696.0, 710.0, 710.0, 710.0, 3.1806615776081424, 1885.986328125, 0.382052123091603], "isController": false}, {"data": ["SearchShoePositive", 5, 0, 0.0, 128.8, 102, 194, 109.0, 194.0, 194.0, 194.0, 5.020080321285141, 3109.7181695532126, 0.5539737073293173], "isController": false}, {"data": ["SearchShoeSortByPrice", 5, 0, 0.0, 577.0, 469, 693, 577.0, 693.0, 693.0, 693.0, 3.1867431485022304, 1846.6205584767367, 0.4107911089866157], "isController": false}, {"data": ["SearchWithSpecialCharacters", 5, 5, 100.0, 41.0, 23, 58, 38.0, 58.0, 58.0, 58.0, 5.973715651135007, 7.647989471326166, 0.7408807497013142], "isController": false}, {"data": ["SearchShoeModelAndNo", 5, 0, 0.0, 489.8, 391, 596, 489.0, 596.0, 596.0, 596.0, 3.663003663003663, 2141.714600503663, 0.5401499542124543], "isController": false}]}, function(index, item){
        switch(index){
            // Errors pct
            case 3:
                item = item.toFixed(2) + '%';
                break;
            // Mean
            case 4:
            // Mean
            case 7:
            // Median
            case 8:
            // Percentile 1
            case 9:
            // Percentile 2
            case 10:
            // Percentile 3
            case 11:
            // Throughput
            case 12:
            // Kbytes/s
            case 13:
            // Sent Kbytes/s
                item = item.toFixed(2);
                break;
        }
        return item;
    }, [[0, 0]], 0, summaryTableHeader);

    // Create error table
    createTable($("#errorsTable"), {"supportsControllersDiscrimination": false, "titles": ["Type of error", "Number of errors", "% in errors", "% in all samples"], "items": [{"data": ["404", 5, 25.0, 8.333333333333334], "isController": false}, {"data": ["403/Forbidden", 5, 25.0, 8.333333333333334], "isController": false}, {"data": ["404/Not Found", 5, 25.0, 8.333333333333334], "isController": false}, {"data": ["499/OK", 5, 25.0, 8.333333333333334], "isController": false}]}, function(index, item){
        switch(index){
            case 2:
            case 3:
                item = item.toFixed(2) + '%';
                break;
        }
        return item;
    }, [[1, 1]]);

        // Create top5 errors by sampler
    createTable($("#top5ErrorsBySamplerTable"), {"supportsControllersDiscrimination": false, "overall": {"data": ["Total", 60, 20, "404", 5, "403/Forbidden", 5, "404/Not Found", 5, "499/OK", 5, "", ""], "isController": false}, "titles": ["Sample", "#Samples", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors"], "items": [{"data": ["SearchInvalidEndpoint", 5, 5, "404/Not Found", 5, "", "", "", "", "", "", "", ""], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": ["SearchWithoutHeaders", 5, 5, "403/Forbidden", 5, "", "", "", "", "", "", "", ""], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": ["SearchWithInvalidRequestType", 5, 5, "404", 5, "", "", "", "", "", "", "", ""], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": ["SearchWithSpecialCharacters", 5, 5, "499/OK", 5, "", "", "", "", "", "", "", ""], "isController": false}, {"data": [], "isController": false}]}, function(index, item){
        return item;
    }, [[0, 0]], 0);

});

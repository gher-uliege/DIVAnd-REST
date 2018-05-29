var SAMPLE_DATA = {
   "observations": "sampledata:WOD-Salinity",
   "varname": "Salinity",
   "bbox": [
      -3.0,
      42.0,
      12.0,
      44.0
   ],
   "depth": [
      0,
      20
   ],
   "len": [
      100000.0,
      100000.0
   ],
   "epsilon2": 1.0,
   "resolution": [
      0.5,
      0.5
   ],
   "years": [
      1993,
      1993
   ],
   "monthlist": [
      [
         1,
         2,
         3
      ],
      [
         4,
         5,
         6
      ],
      [
         7,
         8,
         9
      ],
      [
         10,
         11,
         12
      ]
   ],
   "bathymetry": "sampledata:gebco_30sec_16",
   "metadata": {
      "project": "SeaDataCloud",
      "institution_urn": "SDN:EDMO::1579",
      "production": "Diva group. E-mails: a.barth@ulg.ac.be, swatelet@ulg.ac.be",
      "Author_e-mail": [
         "Your Name1 <name1@example.com>",
         "Other Name <name2@example.com>"
      ],
      "source": "observational data from SeaDataNet/EMODNet Chemistry Data Network",
      "comment": "...",
      "parameter_keyword_urn": "SDN:P35::EPC00001",
      "search_keywords_urn": [
         "SDN:P02::PSAL"
      ],
      "area_keywords_urn": [
         "SDN:C19::3_3"
      ],
      "product_version": "1.0",
      "netcdf_standard_name": "sea_water_salinity",
      "netcdf_long_name": "sea water salinity",
      "netcdf_units": "1e-3",
      "abstract": "...",
      "acknowledgment": "...",
      "doi": "..."
   }
};





function checkAnalysis(url,callback) {
    var xhr = new XMLHttpRequest();
  
    xhr.open("GET", url, true);
    xhr.onreadystatechange = function () {
    
        if (xhr.readyState === 4 && xhr.status === 200) {
            console.log("length",xhr.responseText.length,xhr.getResponseHeader('Cache-Control'));
            var jsonResponse = JSON.parse(xhr.responseText);


            if (jsonResponse.status === "pending") {
                setTimeout(function(){ 
                    console.log("recheck");
                    checkAnalysis(url,callback);
                }, 3000);
            }
            else {
                // done!
                // callback
        	    console.log("ok, done", jsonResponse);
                callback("done",jsonResponse);
            }
        }

    };
    xhr.send(null);


}


/**
 * Represents a DIVAnd REST server
 * @constructor
 * @param {string} baseurl - The base URL of the REST API (without, e.g. /v1/analysis/...)
 */
function DIVAnd(baseurl) {
    this.baseurl = baseurl || "";
}

/**
 * Schedule a DIVAnd analysis
 * @function DIVAnd~analysis
 * @param {string} data - Parameters for the analysis
 * @param {DIVAnd~callback} callback - The callback that handles the response.
 */
DIVAnd.prototype.analysis = function(data,callback) {
    // Sending and receiving data in JSON format using POST method
    //
    var xhr = new XMLHttpRequest();
    var url = this.baseurl + "/v1/analysis";
    var that = this;
    
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 2 && xhr.status === 202) {
            console.log("xhr.getResponseHeader('Location')",xhr.getResponseHeader('Location'));
            callback("processing",{});
             
            var newurl = that.baseurl + xhr.getResponseHeader('Location');
            checkAnalysis(newurl,callback);
        }
    };
    xhr.send(JSON.stringify(data));
    callback("submitted",{});

}

/**
 * This callback is used for notifying the status of the analysis
 * @callback DIVAnd~callback
 * @param {string} step - "submitted","processing","done"
 * @param {object} data - additional data about the status
 */


function callback(step,data) {
    console.log("step",step,data);
    document.getElementById("status").innerHTML = step;

    if (step === "done") {
        var result = document.getElementById("result");
        result.href = data.url;
        result.style.display = "block";
    }
}


function run() {
    var data = SAMPLE_DATA;

    var baseurl = "";
    var divand = new DIVAnd(baseurl);
    
    //requestAnalysis(data,callback);
    divand.analysis(data,callback);
}

function appendform(table,data) {
    for (var key in data) {
        if (data.hasOwnProperty(key)) {
            console.log(key + " -> " + data[key]);

            var tr = document.createElement("tr");
            
            var td = document.createElement("td");
            
            var x = document.createElement("label");
            x.appendChild(document.createTextNode(key));
            td.appendChild(x);
            tr.appendChild(td);
            
            var td = document.createElement("td");    
            var x = document.createElement("input");
            x.setAttribute("type", "text");
            
            if (data[key].constructor === Array) {
                value = data[key].join();
            }
            else if (typeof data[key] === 'object') {

            }
            else {
                value = data[key];
            }
            
            x.setAttribute("value", value);
            
            td.appendChild(x);
            tr.appendChild(td);
    
            table.appendChild(tr);
            
        }
    }
    
}


(function() {
   // your page initialization code here
    // the DOM will be available here


    var table = document.getElementById("DIVAnd_table");
    var data = SAMPLE_DATA;
    appendform(table,data);    
    
    document.getElementById("run").onclick = run;

    
})();

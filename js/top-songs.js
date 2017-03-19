var timer = null;
$(document).keydown(function(){
       clearTimeout(timer); 
       timer = setTimeout(doStuff, 1000)
});

function doStuff() {
    
    var songTitle = document.getElementById("songtitle").value;
    var langElement = document.getElementById("languages");
    var xmlHttp = new XMLHttpRequest();
    var URL = "http://localhost:7040/modules/suggest-auto.xqy?songTitle="+songTitle;
    xmlHttp.open("GET", URL, true); // true for asynchronous 
    xmlHttp.send();
    xmlHttp.onreadystatechange = function() { 
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
            var response = xmlHttp.responseText;
            console.log("respnse-->"+response);
            if(response) {
                console.log("if response exist");
                var response = response.split(",");
                console.log("--"+response[2]+"--");
                while (langElement.firstChild) {
                    langElement.removeChild(langElement.firstChild);
                }
                for(var i in response) {
                    console.log("--"+response[i]+"--");
                    var opt = document.createElement('option');
                    opt.value = response[i];
                    langElement.appendChild(opt);
                }
            }
        }
    }
}
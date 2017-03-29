// グラフ表示は以下のサイトを参考にした。
// http://simalabs.com/labs/smoothiejs
document.addEventListener("pageinit", function(e) {
  if (e.target.id == "status_page") {
    var strwork;
    var jsDate;
    
    jsDate = new Date();

    document.getElementById("status_date").innerHTML =
      jsDate.getFullYear() + "/" + jsDate.getMonth()+1 + "/" + jsDate.getDate() + " " +
      jsDate.getHours() + ":" + jsDate.getMinutes() + ":" + jsDate.getSeconds();
    document.getElementById("status_host").innerHTML = location.host;
    document.getElementById("status_hostname").innerHTML = location.hostname;
    document.getElementById("status_port").innerHTML = location.port;
    document.getElementById("status_request").innerHTML = location.pathname;
    document.getElementById("status_code").innerHTML = navigator.appCodeName;
    document.getElementById("status_browser").innerHTML = navigator.appName;
    document.getElementById("status_version").innerHTML = navigator.appVersion;
    document.getElementById("status_language").innerHTML = navigator.language;
    document.getElementById("status_platform").innerHTML = navigator.platform;
    document.getElementById("status_useragent").innerHTML = navigator.userAgent;
    document.getElementById("status_referrer").innerHTML = document.referrer;
    document.getElementById("status_domain").innerHTML = document.domain;
    document.getElementById("status_screen_w").innerHTML = screen.width;
    document.getElementById("status_screen_h").innerHTML = screen.height;
    document.getElementById("status_screen_depth").innerHTML = screen.colorDepth;

  }
}, false);

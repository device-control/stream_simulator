// グラフ表示は以下のサイトを参考にした。
// http://simalabs.com/labs/smoothiejs
document.addEventListener("pageinit", function(e) {
  if (e.target.id == "smoothie_test_page") {
    var cnt = 10*2; // 500ms単位で入力しているためｘ２している
    // Randomly add a data point every 500ms
    var data1 = new TimeSeries();
    //data1.maxValue = 10000;
    //data1.minValue = 0;
    var data2 = new TimeSeries();
    //data1.maxValue = 10000;
    //data1.minValue = 0;
    var data3 = new TimeSeries();
    //data1.maxValue = 10000;
    //data1.minValue = 0;
    setInterval(function() {
      var time = new Date().getTime();
      if (cnt !== 0){
        cnt--;
        data1.append(time, Math.random() * 10000);
      }
      // else{
      //   data1.append(time, 0);
      // }
      //data1.append(time, Math.random() * 10000);
      data2.append(time, Math.random() * 10000);
      data3.append(time, Math.random() * 10000);
    }, 500);
    
    function createTimeline() {
      // var chart = new SmoothieChart();
      var chart = new SmoothieChart({
        grid: {
          strokeStyle: "rgb(125, 0, 0)",
          fillStyle: "rgb(60, 0, 0)",
          lineWidth: 1,
          millisPerLine: 1e3
        },
        maxValue: 10000,
        minValue: 0,
        timestampFormatter: SmoothieChart.timeFormatter
      }, 2e3);
      
      //chart.addTimeSeries(data1, { strokeStyle: 'rgba(0, 255, 0, 1)', fillStyle: 'rgba(0, 255, 0, 0.2)', lineWidth: 4 });
      //chart.addTimeSeries(data2, { strokeStyle: 'rgba(255, 0, 0, 1)', fillStyle: 'rgba(0, 255, 0, 0.2)', lineWidth: 4 });
      //chart.addTimeSeries(data3, { strokeStyle: 'rgba(0, 0, 255, 1)', fillStyle: 'rgba(0, 255, 0, 0.2)', lineWidth: 4 });
      chart.addTimeSeries(data1, { strokeStyle: 'rgba(0, 255, 0, 1)', lineWidth: 4 });
      chart.addTimeSeries(data2, { strokeStyle: 'rgba(255, 0, 0, 1)', lineWidth: 4 });
      chart.addTimeSeries(data3, { strokeStyle: 'rgba(0, 0, 255, 1)', lineWidth: 4 });
      chart.streamTo(document.getElementById("chart"), 500);
    }
    
    
    createTimeline();
  }
}, false);


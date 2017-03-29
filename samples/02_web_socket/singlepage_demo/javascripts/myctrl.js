ons.bootstrap();
var app = angular.module('myApp', ['onsen']);
app.controller('myCtrl', function($scope, $q) {
  ons.createAlertDialog('dialogs/alert.html').then(function(alertDialog) {
    $scope.alertDialog = alertDialog;
  });
  
  $scope.fromTemplate = function() {
    $scope.alertDialog.show();
  };
  
  $scope.close = function() {
    if($scope.alertDialog && $scope.alertDialog.isShown()) {
      $scope.alertDialog.hide();
    }
  };
  
  $scope.alert = function() {
    ons.notification.alert({message: "Hello, world!"});
  };
  
  $scope.confirm = function() {
    ons.notification.confirm({
      message: "Do you like ramen?",
      buttonLabels: ["Yes", "No"],
      callback: function(i) {
        if (i == 0) {
          ons.notification.alert({message: "Me too!"});
        } else {
          ons.notification.alert({message: "That's too bad..."});
        }
      }
    });
  };
  
  $scope.prompt = function() {
    var fn = function() {
      ons.notification.prompt({
        message: "What is the meaning of Life, the Universe and Everything?",
        callback: function(answer) {
          if (answer === "42") {
            ons.notification.alert({message: "That's the correct answer!"});
          } else {
            ons.notification.alert({
              message: "Incorrect! Please try again!",
              callback: fn
            });
          }
        }
      });
    };
    
    fn();
  };
  
  $scope.cancelable = function() {
    ons.notification.confirm({
      message: "This dialog can be canceled by tapping the background or using the back button on your device.",
      cancelable: true,
      callback: function(i) {
        if (i == -1) {
          ons.notification.alert({message: "You canceled it!"});
        }
      }
    });
  };
});
  

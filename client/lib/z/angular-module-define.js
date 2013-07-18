angular.module( APP.angular.moduleName,['meteor','datePicker','ui.state'])
.config(['$stateProvider', '$urlRouterProvider', function($stateProvider, $urlRouterProvider) {
	$urlRouterProvider.otherwise("/hiring") 
	$stateProvider.state('hiring', {
        url: "/hiring",
        templateUrl: "partials/hiring.html"
    })
    .state('interview',{
    	url :"/interview/:interviewId",
    	templateUrl:"partials/interview.html",
    })

}])


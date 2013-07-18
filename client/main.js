
Meteor.startup(function () {

	// bootstrap
	$("[ng-app]").each(function(){
		angular.bootstrap( $(this), [ $(this).attr("ng-app")])
	})

	// menu
	$(".menu-item a").each(function(){
		$(this).click( function(){
			$(".menu-item a").removeClass("active")
			$(this).addClass("active")
		})
	})

});
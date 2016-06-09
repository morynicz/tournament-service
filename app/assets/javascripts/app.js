angular.module('ippon',[
	'templates',
	'ui.router',
	'ngResource',
	'Devise',
	'pascalprecht.translate'
]);

angular.module('ippon').config([
	'$stateProvider',
	'$urlRouterProvider',
	'$translateProvider',
	function($stateProvider, $urlRouterProvider, $translateProvider) {
		$stateProvider.state('home',{
			url: '/home',
			templateUrl: 'Home/_index.html',
			controller: 'HomePageController'
		})
		.state('clubs', {
			url: '/clubs',
			templateUrl: 'Clubs/_index.html',
			controller: 'ClubsController'
		})
		.state('clubs_new',{
			url: '/clubs/new',
			templateUrl: 'Clubs/_form.html',
			controller: 'ClubsController'
		})
		.state('clubs_show',{
			url: '/clubs/:clubId',
			templateUrl: 'Clubs/_show.html',
			controller: 'ClubsController'
		})
		.state('clubs_edit', {
			url: '/clubs/:clubId/edit',
			templateUrl: 'Clubs/_form.html',
			controller: 'ClubsController'
		})
		.state('login',{
			url: '/login',
			templateUrl: 'auth/_login.html',
			controller: 'AuthController',
			onEnter: ['$state', 'Auth', function($state, Auth) {
				Auth.currentUser().then(function() {
					$state.go('home');
				});
			}]
		})
		.state('register', {
			url: '/register',
			templateUrl: 'auth/_register.html',
			controller: 'AuthController'
		});;

		$urlRouterProvider.otherwise('home');

		$translateProvider.translations('en', {
			CLUBS: "Clubs",
			HOME: "Home Page",

			LANGUAGE: "Language",

			LOG_IN: "Log In",
			REGISTER: "Register",
			LOG_OUT: "Log Out",

			ADD: "Add",
			EDIT: "Edit",
			DELETE: "Delete",
			CANCEL: "Cancel",
			SAVE: "Save",
			INDEX: "Index",

			HOME_TITLE: "Ippon Home Page",
			HOME_TEXT: "Here shall be some links",

			CLUB_NAME: "Name",
			CLUB_NAME_PLACEHOLDER: "Osoms",
			CLUB_CITY: "City",
			CLUB_CITY_PLACEHOLDER: "Samuraiville",
			CLUB_DESCRIPTION: "Description",
			CLUB_DESCRIPTION_PLACEHOLDER: "Strongest club around"
		})
		.translations('pl', {
			CLUBS: "Kluby",
			HOME: "Strona Domowa",

			LANGUAGE: "Język",

			LOG_IN: "Zaloguj",
			REGISTER: "Zarejestruj",
			LOG_OUT: "Wyloguj",

			ADD: "Dodaj",
			EDIT: "Edytuj",
			DELETE: "Usuń",
			CANCEL: "Anuluj",
			SAVE: "Zapisz",
			INDEX: "Spis",

			HOME_TITLE: "Strona domowa Ippon",
			HOME_TEXT: "Tu pojawią się linki",

			CLUB_NAME: "Nazwa",
			CLUB_NAME_PLACEHOLDER: "Superkai",
			CLUB_CITY: "Miasto",
			CLUB_CITY_PLACEHOLDER: "Samurajów",
			CLUB_DESCRIPTION: "Opis",
			CLUB_DESCRIPTION_PLACEHOLDER: "Najlepszy klub w okolicy"
		});

		$translateProvider.useSanitizeValueStrategy('escape');
		$translateProvider.preferredLanguage('en');

	}]);

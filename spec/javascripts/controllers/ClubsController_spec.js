describe('ClubsController', function() {
  var scope = null;
  var ctrl = null;
  var location = null;
  var stateParams = null;
  var resource = null;
  var httpBackend = null;
  var clubId = 42;
  var state;

  var fakeClub = {
    id: clubId,
    name: "FakinClub",
    city: "Fakeville",
    description: "They are far from being real"
  };

  var setupController = function(clubExists, clubId, results, stateName, stateData = null) {
    return inject(function($location, $stateParams, $rootScope, $resource, $httpBackend, $controller, $state, $templateCache) {
      scope = $rootScope.$new();
      location = $location;
      resource = $resource;
      stateParams = $stateParams;
      httpBackend = $httpBackend;

      state = $state;

      $templateCache.put('Clubs/_index.html','');
      $templateCache.put('Clubs/_show.html','');
      $templateCache.put('Clubs/_form.html','');

      if(stateData === null) {
        state.go(stateName);
      } else {
        state.go(stateName, stateData);
      }
      $rootScope.$apply();
      var request = null;

      if(results) {
        request = new RegExp("clubs");
        httpBackend.expectGET(request).respond(results);
      } else if (clubId) {
        stateParams.clubId = clubId;
        request = new RegExp("clubs/" + clubId);
        results = (clubExists)?[200, fakeClub]:[404];
        httpBackend.expectGET(request).respond(results[0], results[1]);
      }

      ctrl = $controller('ClubsController', {
        $scope: scope,
        $location: location,
        $state: state
      });
    });
  };

  var setupPlayers = function(clubId,players) {
    if(players == null) {
      players = [];
    }
    httpBackend.expectGET(new RegExp("clubs/" + clubId + "/players")).respond(players);
  };

  var setupAdmins = function(clubId,admins,users) {
    if(admins == null) {
      admins = [];
    }
    httpBackend.expectGET(new RegExp("clubs/" + clubId + "/admins")).respond({
      admins: admins,
      users: users
    });
  };

  beforeEach(module('ippon'));

  afterEach(function(){
    httpBackend.verifyNoOutstandingExpectation();
    httpBackend.verifyNoOutstandingRequest();
  });

  describe('index', function(){
    var clubs = [
      {
        id: 2,
        name: 'Ryushinkai',
        city: 'Wrocław',
        description: 'Najlepszy klub'
      },
      {
        id: 7,
        name: 'Nowoklub',
        city: 'Daleków',
        description: 'Świeżaki'
      }
    ];

    beforeEach(function(){
      setupController(false,false,clubs,'clubs');
      httpBackend.flush();
    });
    it('calls the back-end', function() {
      expect(scope.clubs).toEqualData(clubs);
    });
  });

  describe('show',function(){
    describe('club is found', function() {
      var players = [
        {
          id:96,
          name:"Laverne",
          surname:"Ratke",
          birthday:"2008-07-03",
          rank:"kyu_5",
          sex:"male",
          club_id:112
        }
      ];
      var admins = [
        {
          id: "0",
          username: "uname"
        }
      ];
      beforeEach(function() {
        setupController(true,42,false,'clubs_show', {clubId: 42});
        setupPlayers(42,players);
        setupAdmins(42,admins,[]);
      });
      it('loads the given club', function() {
        httpBackend.flush();
        expect(scope.club).toEqualData(fakeClub);
        expect(scope.players).toEqualData(players);
        expect(scope.admins).toEqualData(admins);
        expect(scope.users).toEqualData([]);
      });
    });

    describe('club is not found', function() {
      beforeEach(setupController(false,42,false,'clubs_show', {clubId: 42}));
      it('loads given club', function() {
        httpBackend.flush();
        expect(scope.club).toBe(null);
        //flash about error
      });
    });
  });

  describe('create', function() {
    var newClub = {
      id: 64,
      name: 'Storm Club',
      city: 'Crab City',
      description: 'Very marine club'
    };

    beforeEach(function() {
      setupController(false, false, false, 'clubs_new');
      var request = new RegExp("\/clubs");
      httpBackend.expectPOST(request).respond(201, newClub);
    });

    it('post to the backend', function() {
      scope.club.name = newClub.name;
      scope.club.city = newClub.city;
      scope.club.description = newClub.description;
      scope.save();
      scope.$apply();
      httpBackend.flush();
      expect('#' + location.path()).toBe(state.href('clubs_show'));
      expect(state.is('clubs_show')).toBe(true);
    });
  });

  describe('update', function() {
    var updatedClub = {
      name: "Updated Club",
      city: "Updated Town",
      description: "Updated as hell"
    };

    beforeEach(function() {
      setupController(true, 42,false,'clubs_edit', {clubId: 42});
      httpBackend.flush();
      var request = new RegExp("clubs/");
      httpBackend.expectPUT(request).respond(204);
    });

    it('posts to the backend', function() {
      scope.club.name = updatedClub.name;
      scope.club.city = updatedClub.city;
      scope.club.describe = updatedClub.description;
      scope.save();
      httpBackend.flush();
      expect('#'+location.path()).toBe(state.href('clubs_show',{clubId: scope.club.id}));
      expect(state.is('clubs_show')).toBe(true);
    });
  });

  describe('delete', function() {
    beforeEach(function() {
      setupController(true,42,false,'clubs_show', {clubId: 42});
      setupPlayers(42,null);
      setupAdmins(42,null,[]);
      httpBackend.flush();
      var request = new RegExp("clubs/" + scope.club.id);
      httpBackend.expectDELETE(request).respond(204);
    });

    it('posts to the backend', function() {
      scope["delete"]();
      scope.$apply();
      httpBackend.flush();
      expect('#'+ location.path()).toBe(state.href('clubs'));
    });
  });
});

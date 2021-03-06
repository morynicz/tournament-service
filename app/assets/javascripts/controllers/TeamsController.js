angular.module('ippon').controller('TeamsController',[
  '$scope',
  '$stateParams',
  '$location',
  '$resource',
  '$state',
  'Auth',
  'FlashingService',
  function($scope, $stateParams, $location, $resource, $state, Auth, FlashingService){

    var teamResource = $resource("/teams/:teamId",
    {
      teamId: "@id",
      format: "json"
    }, {
      'save': {
        method: 'PUT'
      },
      'create': {
        method: 'POST'
      },
      'add_member' : {
        method: 'PUT',
        url: '/teams/:teamId/add_member/:playerId',
        params: {
          teamId: "@teamId",
          playerId: "@playerId"
        }
      },
      'delete_member' : {
        method: 'DELETE',
        url: '/teams/:teamId/delete_member/:playerId'
      }
    });

    var getTeam = function(teamId, next) {
      teamResource.get({
        teamId: teamId
      }, function(response) {
        $scope.team = response.team;
        $scope.members = response.players;
        $scope.is_admin = response.is_admin;
        if(next) {
          next();
        }
      }, function(httpResponse) {
        $scope.team = null;
        $scope.members = null;
        $scope.is_admin = false;
        FlashingService.flashRestFailed("{{'FIND' | translate}}",
          "{{'TEAM'  |translate}}", httpResponse);
      });
    }

    var tournamentResource = $resource("/tournaments/:tournamentId",
    {
      tournamentId: "@id",
      format: "json"
    },{
      'participants' : {
        method: 'GET',
        isArray: true,
        url: "/tournaments/:tournamentId/participants"
      },
      'unassigned' : {
        method: 'GET',
        isArray: true,
        url: "/tournaments/:tournamentId/participants/unassigned",
        params: {
          tournamentId: "@tournamentId"
        }
      }
    });

    var getAvailablePlayers = function() {
      tournamentResource.unassigned({tournamentId: $scope.team.tournament_id}, function(results) {
        $scope.players = results;
      }, function(httpResponse) {
        $scope.players = null;
        FlashingService.flashRestFailed("{{'FIND' | translate}}",
          "{{'PLAYER' |translate}}", httpResponse);
      });
    }

    $scope.backFcn = null
    if($stateParams.teamId && ($state.is('teams_show') || $state.is('teams_edit'))) {
      if($state.is('teams_edit')) {
        getTeam($stateParams.teamId, getAvailablePlayers);
      } else {
        getTeam($stateParams.teamId);
        $scope.backFcn = $stateParams.backFcn;
      }
    } else {
      $scope.team = {};
      $scope.team.tournament_id = $stateParams.tournamentId;
    }

    $scope.save = function() {
      var onError = function(_httpResponse) {
        FlashingService.flashRestFailed("{{'SAVE' | translate}}",
          "{{'TEAM' |translate}}", httpResponse);
      };

      if($scope.team.id) {
        teamResource.save($scope.team, function() {
          $state.go('teams_show',{teamId: $scope.team.id});
        }, onError);
      } else {
        teamResource.create($scope.team, function(newTeam) {
          $state.go('teams_show',{teamId: newTeam.id});
        }, onError);
      }
    };

    $scope["delete"] = function() {
      teamResource.delete({teamId: $scope.team.id});
      $state.go('home');
    }

    $scope.add_member = function(playerId) {
      teamResource.add_member({teamId: $scope.team.id, playerId: playerId},
      function() {
        getTeam($scope.team.id, getAvailablePlayers);
      });
    };

    $scope.delete_member = function(playerId) {
      teamResource.delete_member({teamId: $scope.team.id, playerId: playerId},
      function() {
        getTeam($scope.team.id, getAvailablePlayers);
      });
    };

    $scope.edit = function() {
      $state.go('teams_edit',{teamId: $scope.team.id});
    };

    $scope.cancel = function() {
      if($scope.team.id) {
        $state.go('teams_show',{teamId: $scope.team.id});
      } else if ($scope.team && $scope.team.tournament_id) {
        $state.go('tournaments_show', {tournamentId: $scope.team.tournament_id});
      } else {
        $state.go('home');
      }
    };

    $scope.back = function() {
      if ($scope.backFcn) {
        $scope.backFcn();
      } else if ($scope.team && $scope.team.tournament_id) {
        $state.go('tournaments_show', {tournamentId: $scope.team.tournament_id});
      } else {
        $state.go('home');
      }
    };
  }]);

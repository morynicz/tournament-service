require 'rails_helper'

RSpec.describe TeamsController, type: :controller do
  render_views

  def extract_player_name
    ->(object) { object["name"]}
  end

  def extract_surname
    ->(object) {object["surname"]}
  end

  def extract_birthday
    ->(object) {object["birthday"]}
  end

  def extract_rank
    ->(object) {object["rank"]}
  end

  def extract_sex
    ->(object) {object["sex"]}
  end

  def extract_club
    ->(object) {object["club_id"]}
  end

  def extract_id
    ->(object) { object["id"]}
  end

  def extract_name
    ->(object) { object["name"]}
  end

  def extract_players
    ->(object) { object["players"]}
  end

  def extract_team
    ->(object) { object["team"] }
  end

  def check_array_for_players(result, expected)
    for player in expected do
      expect(result.map(&extract_name)).to include(player.name)
      expect(result.map(&extract_surname)).to include(player.surname)
      expect(result.map(&extract_birthday)).to include(player.birthday)
      expect(result.map(&extract_rank)).to include(player.rank)
      expect(result.map(&extract_sex)).to include(player.sex)
      expect(result.map(&extract_club)).to include(player.club)
      expect(result.map(&extract_id)).to include(player.id)
    end
  end

  def authorize_user(tournament_id)
    TournamentAdmin.create(tournament_id: tournament_id, user_id: current_user.id, status: :main)
  end

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET show" do
    let(:action) {
      xhr :get, :show, format: :json, id: team_id
    }

    subject(:results) {JSON.parse(response.body)}

    context "when the team exists" do
      let(:player_list) {
        FactoryGirl::create_list(:player,3)
      }
      let(:team) {
        to = FactoryGirl::create(:tournament, team_size: 3)
        FactoryGirl::create(:team, tournament: to)
      }
      let(:team_id){team.id}

      before do
        team
        player_list
        for player in player_list do
          TeamMembership.create(player_id: player.id, team_id: team.id)
        end
      end

      it "should return 200 status" do
        action
        expect(response.status).to eq(200)
      end

      it "should return result with correct id" do
        action
        expect(results["team"]["id"]).to eq(team.id)
      end

      it "should return result with correct name" do
        action
        expect(results["team"]["name"]).to eq(team.name)
      end

      it "should return result with correct tournament id" do
        action
        expect(results["team"]["tournament_id"]).to eq(team.tournament_id)
      end

      it "should return players with proper values" do
        action
        for player in player_list do
          expect(results["players"].map(&extract_player_name)).to include(player.name)
          expect(results["players"].map(&extract_surname)).to include(player.surname)
          expect(results["players"].map(&extract_club)).to include(player.club_id)
        end
      end

      context "when the user is not an admin" do
        it "should return admin status false" do
          action
          expect(results["is_admin"]).to be false
        end
      end

      context "when the user is an admin", authenticated: true do
        context "when the user is not an admin" do
          it "should return admin status true" do
            authorize_user(team.tournament.id)
            action
            expect(results["is_admin"]).to be true
          end
        end
      end
    end

    context "when team doesn't exist" do
      let(:team_id) {-9999}
      it "should respond with 404 status" do
        action
        expect(response.status).to eq(404)
      end
    end
  end

  describe "GET index" do
    let(:tournament) {
      FactoryGirl::create(:tournament)
    }

    let(:team_list) {
      FactoryGirl::create_list(:team, 10, tournament: tournament)
    }

    let(:action) {
      xhr :get, :index, format: :json, tournament_id: tournament.id
    }

    subject(:results) { JSON.parse(response.body)}

    context "when we want the full list" do
      it "should return 200 status" do
        team_list
        action
        expect(response.status).to eq(200)
      end

      it "should return 10 results" do
        team_list
        action
        expect(results.size).to eq(tournament.teams.size)
      end

      it "should include name and id of the team" do
        team_list
        action

        for team in team_list do
          expect(results.map(&extract_team).map(&extract_name)).to include(team.name)
          expect(results.map(&extract_team).map(&extract_id)).to include(team.id)
        end
      end

      it "should contain all the members of all teams" do
        team_list
        action

        extracted_players = results.map(&extract_players).flatten

        for team in team_list do
          check_array_for_players(extracted_players, team.players)
        end
      end
    end
  end

  describe "POST :create" do
    let(:tournament) {
      FactoryGirl::create(:tournament)
    }

    let(:attributes) {  FactoryGirl.attributes_for(:team, tournament_id: tournament.id) }
    let(:action) do
        xhr :post, :create, format: :json, team: attributes, tournament_id: tournament.id
    end

    context "when the user is not authenticated" do
      it "does not create a Team" do
        expect {
          action
        }.to_not change(Team, :count)
      end

      it "denies access" do
        action
        expect(response).to have_http_status :unauthorized
      end
    end

    context "when the user is authenticated", authenticated: true do
      context "when user is authorized" do
        before do
          authorize_user(tournament.id)
        end

        context "with invalid attributes" do

          let(:attributes) do
            {
              name: ''
            }
          end

          it "does not create a team" do
            expect {
              action
            }.to_not change(Team, :count)
          end

          it "returns the correct status" do
            action
            expect(response).to have_http_status :unprocessable_entity
          end
        end
        context "with valid attributes" do
          it "creates a team" do
            expect {
              action
            }.to change(Team, :count).by(1)
          end

          it "returns the correct status" do
            action
            expect(response).to be_successful
          end
        end
      end

      context "when the user is not authorized" do
        it "should respond with unauthorized status" do
          action
          expect(response).to have_http_status :unauthorized
        end

        it "does not create a player" do
          expect {
            action
          }.to_not change(Team, :count)
        end
      end
    end
  end

  describe "PATCH update" do
    let(:tournament) {
      FactoryGirl::create(:tournament)
    }

    let(:action) {
      xhr :put, :update, format: :json, id: team.id, team: update_team_attrs
      team.reload
    }

    let(:update_team_attrs) {
      FactoryGirl::attributes_for(:team)
    }
    let(:team_attrs) {
      FactoryGirl::attributes_for(:team, tournament_id: tournament.id)
    }
    context "when the team exists" do
      let(:team) {
        Team.create(team_attrs)
      }

      context "when the user is authorized", authenticated: true do
        before do
          authorize_user(tournament.id)
        end
        context "when the update atttributes are valid" do
          it "should return correct status" do
            action
            expect(response.status).to eq(204)
          end

          it "should update team attributes" do
            action
            expect(team.name).to eq(update_team_attrs[:name])
          end
        end

        context "when the update attributes are not valid" do
          let(:update_team_attrs) {
            {
              name: '',
              tournament_id: ''
            }
          }

          it "should not update team attributes" do
            action
            expect(team.name).to eq(team_attrs[:name])
            expect(team.tournament_id).to eq(team_attrs[:tournament_id])
          end

          it "should return unporcessable entity" do
            action
            expect(response).to have_http_status :unprocessable_entity
          end
        end
      end

      context "when the user isn't authorized" do
        it "should respond with unauthorized status" do
          action
          expect(response).to have_http_status :unauthorized
        end

        it "should not update team attributes" do
          action
          expect(team.name).to eq(team_attrs[:name])
          expect(team.tournament_id).to eq(team_attrs[:tournament_id])
        end
      end
    end

    context "when the team doesn't exist" do
      let(:team_id) {-9999}

      let(:action) {
        xhr :put, :update, format: :json, id: team_id, team: update_team_attrs
      }

      context "when user is not authorized" do
        it "should respond with unauthorized status" do
          action
          expect(response).to have_http_status :unauthorized
        end
      end
    end
  end

  describe "DELETE: destroy" do
    let(:tournament) {
      FactoryGirl::create(:tournament)
    }

    let(:action) {
        xhr :delete, :destroy, format: :json, id: team_id
    }

    let(:player_list) {
      FactoryGirl::create_list(:player,3)
    }
    context "when the team exists" do
      let(:team) {
        team = FactoryGirl::create(:team, tournament_id: tournament.id)
        for player in player_list do
          TeamMembership.create(player_id: player.id, team_id: team.id)
        end
        team
      }
      let(:team_id){team.id}

      context "when the user is authorized", authenticated: true do
        before do
          authorize_user(tournament.id)
        end
        it "should respond with 204 status" do
          action
          expect(response.status).to eq(204)
        end

        it "should not be able to find deleted team" do
          action
          expect(Team.find_by_id(team.id)).to be_nil
        end

        it "should destroy all memberships of this team" do
          action
          expect(TeamMembership.exists?(team_id: team_id)).to be false
        end
      end

      context "when the user is not authorized" do
        it "should respond with unauthorized status" do
          action
          expect(response).to have_http_status :unauthorized
        end
        it "should not delete the team" do
          action
          expect(Team.exists?(team.id)).to be true
        end
      end
    end

    context "when the team doesn't exist" do
      let(:team_id) {-9999}

      context "when the user is not authorized" do
        it "should respond with unauthorized status" do
          action
          expect(response).to have_http_status :unauthorized
        end
      end

      context "when the user is authorized", authenticated: true do
        before do
          authorize_user(tournament.id)
        end
        it "should respond with not found status" do
          action
          expect(response).to have_http_status :not_found
        end
      end
    end
  end

  describe "PUT: add_member" do
    let(:tournament) {
      FactoryGirl::create(:tournament)
    }

    let(:player) {
      FactoryGirl::create(:player)
    }

    let(:action) {
        xhr :put, :add_member, format: :json, id: team_id, player_id: player_id
    }
    let(:player_id){player.id}

    let(:team) {
      FactoryGirl::create(:team, tournament_id: tournament.id)
    }
    let(:team_id){team.id}

    context "when the user is not authorized" do
      it "should respond with unauthorized status" do
        action
        expect(response).to have_http_status :unauthorized
      end
      it "should not change number of team memberships" do
        expect{
          action
        }.not_to change(TeamMembership, :count)
      end
    end

    context "when the user is authorized", authenticated: true do
      before do
        authorize_user(tournament.id)
      end

      context "when the team exists" do
        context "when the player does not exist" do
          let(:player_id){-9999}
          it "should respond with not found status" do
            action
            expect(response).to have_http_status :not_found
          end
          it "should not change number of team memberships" do
            expect{
              action
            }.not_to change(TeamMembership, :count)
          end
        end

        context "when the player exists" do
          context "when the membership desn't exists yet" do
            context "when there are still members missing" do
              it "should respond with OK status" do
                action
                expect(response).to have_http_status :no_content
              end
              it "should not change number of team memberships" do
                expect{
                  action
                }.to change(TeamMembership, :count).by(1)
              end
              it "should create a team membership for the player and team" do
                action
                expect(TeamMembership.exists?(team_id: team_id, player_id: player_id)).to be true
              end
            end

            context "when the team is full" do
              before do
                FactoryGirl::create_list(:team_membership, (team.tournament.team_size - team.players.size) , team: team)
              end
              it "should respond with unauthorized status" do
                action
                expect(response).to have_http_status :conflict
              end
              it "should not change number of team memberships" do
                expect{
                  action
                }.not_to change(TeamMembership, :count)
              end
            end
          end

          context "when the membership exists already" do
            before do
              TeamMembership.create(team_id: team_id, player_id: player_id)
            end
            it "should respond with not found status" do
              action
              expect(response).to have_http_status :conflict
            end

            it "should not change number of team memberships" do
              expect{
                action
              }.not_to change(TeamMembership, :count)
            end
          end
        end
      end

      context "when the team doesn't exist" do
        let(:team_id) {-9999}
        it "should respond with not found status" do
          action
          expect(response).to have_http_status :not_found
        end
        it "should not change number of team memberships" do
          expect{
            action
          }.not_to change(TeamMembership, :count)
        end
      end
    end
  end

  describe "DELETE: delete_member" do
    let(:tournament) {
      FactoryGirl::create(:tournament)
    }

    let(:player) {
      FactoryGirl::create(:player)
    }

    let(:action) {
        xhr :put, :delete_member, format: :json, id: team_id, player_id: player_id
    }
    let(:player_id){player.id}

    let(:team) {
      FactoryGirl::create(:team, tournament_id: tournament.id)
    }
    let(:team_id){team.id}

    context "when the user is not authorized" do
      it "should respond with unauthorized status" do
        action
        expect(response).to have_http_status :unauthorized
      end
      it "should not change number of team memberships" do
        expect{
          action
        }.not_to change(TeamMembership, :count)
      end
    end

    context "when the user is authorized", authenticated: true do
      before do
        authorize_user(tournament.id)
      end

      context "when the team exists" do
        context "when the player does not exist" do
          let(:player_id){-9999}
          it "should respond with not found status" do
            action
            expect(response).to have_http_status :not_found
          end
          it "should not change number of team memberships" do
            expect{
              action
            }.not_to change(TeamMembership, :count)
          end
        end

        context "when the player exists" do
          context "when the membership exists" do
            before do
              TeamMembership.create(team_id: team_id, player_id: player_id)
            end
            it "should respond with OK status" do
              action
              expect(response).to have_http_status :no_content
            end
            it "should change number of team memberships" do
              expect{
                action
              }.to change(TeamMembership, :count).by(-1)
            end
            it "should create a team membership for the player and team" do
              action
              expect(TeamMembership.exists?(team_id: team_id, player_id: player_id)).to be false
            end
          end
        end

        context "when the membership doesn't exist" do
          it "should respond with not found status" do
            action
            expect(response).to have_http_status :not_found
          end

          it "should not change number of team memberships" do
            expect{
              action
            }.not_to change(TeamMembership, :count)
          end
        end
      end

      context "when the team doesn't exist" do
        let(:team_id) {-9999}
        it "should respond with not found status" do
          action
          expect(response).to have_http_status :not_found
        end
        it "should not change number of team memberships" do
          expect{
            action
          }.not_to change(TeamMembership, :count)
        end
      end
    end
  end
end

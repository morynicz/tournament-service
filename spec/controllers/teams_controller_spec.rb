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
        FactoryGirl::create(:team, required_size: 3)
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

      it "should return result with correct required size" do
        action
        expect(results["team"]["required_size"]).to eq(team.required_size)
      end

      it "should return players with proper values" do
        action
        for player in player_list do
          expect(results["players"].map(&extract_player_name)).to include(player.name)
          expect(results["players"].map(&extract_surname)).to include(player.surname)
          expect(results["players"].map(&extract_club)).to include(player.club_id)
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

  describe "POST :create" do
    let(:tournament) {
      FactoryGirl::create(:tournament)
    }

    let(:attributes) {  FactoryGirl.attributes_for(:team, tournament_id: tournament.id) }
    let(:action) do
        xhr :post, :create, format: :json, team: attributes
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
              name: '',
              required_size: ''
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
end

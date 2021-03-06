require 'spec_helper.rb'

feature 'Creating editing and deleting a club', js: true do
  let(:club1){ FactoryGirl::create(:club)}
  let(:club2){ FactoryGirl::create(:club)}
  let(:pl1) { FactoryGirl::attributes_for(:player, club_id: club1.id)}
  let(:pl2) { FactoryGirl::attributes_for(:player, club_id: club2.id)}
  let(:user) { FactoryGirl::create(:user) }

  before do
    visit "#/home"
    visit "#/login"
    fill_in "email", with: user.email
    fill_in "password", with: user.password

    click_on "log-in-button"
    visit "#/home/"
  end

  scenario "Create a player from player index when user exists and is a club admin", :raceable do
    ClubAdmin.create(user_id: user.id, club_id: club1.id)
    visit "#/players/"

    click_on "new-player"
    fill_in "name", with: pl1[:name]
    fill_in "surname", with: pl1[:surname]
    fill_in "birthday", with: pl1[:birthday]
    if pl1[:sex] == :man
      choose "button-sex-man"
    else
      choose "button-sex-woman"
    end
    select club1.name, from: "club-select"
    tokens = pl1[:rank].split('_')
    select "#{tokens[1]} #{tokens[0].upcase}", from: "rank-select"

    click_on "save-player"

    expect(page).to have_content(pl1[:name])
    expect(page).to have_content(pl1[:surname])
    expect(page).to have_content("#{tokens[1]} #{tokens[0].upcase}")
    expect(page).to have_content(club1.name)
  end

  scenario "Create a player from club view when user exists and is a club admin", :raceable do
    ClubAdmin.create(user_id: user.id, club_id: club1.id)
    visit "#/clubs/"

    click_on club1.name
    click_on "new-player"

    fill_in "name", with: pl1[:name]
    fill_in "surname", with: pl1[:surname]
    fill_in "birthday", with: pl1[:birthday]
    if pl1[:sex] == :man
      choose "button-sex-man"
    else
      choose "button-sex-woman"
    end
    tokens = pl1[:rank].split('_')
    select "#{tokens[1]} #{tokens[0].upcase}", from: "rank-select"

    click_on "save-player"

    expect(page).to have_content(pl1[:name])
    expect(page).to have_content(pl1[:surname])
    expect(page).to have_content("#{tokens[1]} #{tokens[0].upcase}")
    expect(page).to have_content(club1.name)
  end

  scenario "Update a player when user exists and is a club admin", :raceable do
    ClubAdmin.create(user_id: user.id, club_id: club1.id)
    club2
    Player.create(pl1)
    visit "#/players/"

    click_on "#{pl1[:name]} #{pl1[:surname]}"
    click_on "edit-player"

    fill_in "name", with: pl2[:name]
    fill_in "surname", with: pl2[:surname]
    fill_in "birthday", with: pl2[:birthday]
    if pl2[:sex] == :man
      choose "button-sex-man"
    else
      choose "button-sex-woman"
    end
    select club2.name, from: "club-select"
    tokens = pl2[:rank].split('_')
    select "#{tokens[1]} #{tokens[0].upcase}", from: "rank-select"

    click_on "save-player"

    expect(page).to have_content(pl2[:name])
    expect(page).to have_content(pl2[:surname])
    expect(page).to have_content("#{tokens[1]} #{tokens[0].upcase}")
    expect(page).to have_content(club2.name)
  end

  scenario "Delete a player when user is club admin" do
    ClubAdmin.create(user_id: user.id, club_id: club1.id)
    player = Player.create(pl1)
    visit "#/players/"

    click_on "#{player.name} #{player.surname}"
    click_on "delete-player"

    expect(Player.exists?(id: player.id)).to be false
  end
end

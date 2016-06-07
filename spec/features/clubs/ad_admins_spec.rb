require 'spec_helper.rb'

feature "Adding and removing admins", js: true do
  let(:not_admins) {
    FactoryGirl::create_list(:user,5)
  }

  let(:admins) {
    FactoryGirl::create_list(:user,4)
  }

  let(:club) {
    FactoryGirl::create(:club)
  }

  before do
    admins.each do |admin|
      ClubAdmin.create(club_id: club.id, user_id: admin.id)
    end

    adm = admins.first
    not_adm = not_admins.second

    visit '#/login'

    fill_in "email", with: adm.email
    fill_in "password", with: adm.password

    click_on "Log In"
    visit "#/home"
  end

  scenario "Add an admin" do
    visit "#/clubs/"
    visit "#/clubs/"

    click_on club.name
    within('h1', :text =>"#{not_admins[0].username}") do
      click_on "Add"
    end

    within('h1', :text =>"#{not_admins[0].username}") do
      expect(page).to have_button('delete-admin')
    end
  end

  scenario "Delete an admin" do
    visit "#/clubs/"
    visit "#/clubs/"

    click_on club.name

    within('h1', :text =>"#{admins[3].username}") do
      click_on "Delete"
    end

    within('h1', :text =>"#{admins[3].username}") do
      expect(page).to have_button('add-admin')
    end

  end
end

FactoryGirl.define do
  factory :fight do
    team_fight
    state :not_started
    association :aka, factory: :player
    association :shiro, factory: :player

    after(:create) do |fight|
      TeamMembership.create(team: fight.team_fight.aka_team,
        player: fight.aka)
      TeamMembership.create(team: fight.team_fight.shiro_team,
        player: fight.shiro)

      if !TournamentParticipation.exists?(tournament: fight.tournament,
          player: fight.aka)

        TournamentParticipation.create(tournament: fight.tournament,
          player: fight.aka)
      end
      if !TournamentParticipation.exists?(tournament: fight.tournament,
          player: fight.shiro)
        TournamentParticipation.create(tournament: fight.tournament,
          player: fight.shiro)
      end
    end

    factory :fight_with_points do
      transient do
        points_count 1
      end

      after(:create) do |fight, evaluator|
        FactoryGirl::create_list(:point, evaluator.points_count, fight: fight)
      end
    end
  end
end

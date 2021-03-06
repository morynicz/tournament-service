class Club < ActiveRecord::Base
  has_many :club_admins, dependent: :destroy
  has_many :admins, through: :club_admins, source: :user
  has_many :players, dependent: :nullify
  after_commit :add_admin, on: :create
  attr_accessor :creator
  validates :name, :city, presence: true

  def add_admin
    if @creator != nil
      ClubAdmin.create(club_id: self.id, user_id: @creator.id) unless ClubAdmin.exists?(club_id: self.id, user_id: @creator.id)
    end
  end
end

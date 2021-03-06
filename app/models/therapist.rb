class Therapist < ActiveRecord::Base
  has_many :events, dependent: :destroy
  has_many :bills, dependent: :destroy

  store :options, accessors: [:bank, :blz, :konto_nr, :phone, :send_reminders]

  before_validation :assign_full_name

  validates_presence_of :last_name, :first_name, :category, :abbrv

  def self.abbreviations
    all.map(&:abbrv)
  end

  def title
    full_name
  end

  def unbilled_items(before = Date.current.end_of_month)
    unbilled_events = events.includes(:event_category).unbilled(before).by_name
    BillItem.from_events(unbilled_events)
  end

  def send_reminders?
    send_reminders.to_s == 'true' && phone.present?
  end

  private

  def assign_full_name
    self.full_name = [first_name, last_name].compact.join(" ")
  end

end

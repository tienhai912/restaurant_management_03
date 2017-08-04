class Bill < ApplicationRecord
  has_many :bill_details

  belongs_to :customer
  belongs_to :order

  validates :customer, presence: true
  validates :order, presence: true
  validates :discount, presence: true, numericality: {only_integer: true}

  find_table = lambda do |capacity, day, hour_end, hour_start|
    where(
      "capacity >= ? AND id NOT IN (?)", capacity, Order.where(
        "day = ? AND time(time_in) < time(?)
        AND time(time_in) > time(?) AND
        (status NOT IN ('approved', 'done', 'serving'))",
        day, hour_end, hour_start
      ).select("table_id")
    )
  end

  created_at_between = lambda do |datefrom, dateto|
    where(created_at: datefrom..dateto)
  end

  scope :created_at_between, created_at_between

  scope :in_month, ->(month){where("month(created_at) = (?)", month)}

  def total
    total_price_bill_details * (100 - discount - membership_discount) / 100
  end

  def total_price_bill_details
    total = 0
    bill_details.each do |bill_detail|
      total += bill_detail.total_price
    end
    total
  end
end

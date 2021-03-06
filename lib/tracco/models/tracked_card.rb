require 'tracco/mongoid_helper'

module Tracco
  class TrackedCard
    include Mongoid::Document
    include Mongoid::Timestamps
    extend MongoidHelper

    field :name
    field :description, as: :desc
    field :short_id,    type: Integer
    field :trello_id
    field :done,        type: Boolean
    field :due,         type: Date
    field :closed,      type: Boolean
    field :url
    field :pos

    embeds_many :estimates
    embeds_many :efforts

    validates_presence_of :name, :short_id, :trello_id
    validates_numericality_of :short_id

    scope :with_effort_spent_by, ->(username){ where("efforts.members.username" => username) }

    def self.find_by_trello_id(trello_id)
      without_mongo_raising_errors do
        find_by(trello_id: trello_id)
      end
    end

    def self.update_or_create_with(trello_card)
      tracked_card = find_or_create_by(trello_id: trello_card.id)
      trello_card.attributes.delete(:id)
      tracked_card_attributes = trello_card.attributes.merge(done: trello_card.in_done_column?)
      updated_successfully = tracked_card.update_attributes(tracked_card_attributes)
      return tracked_card if updated_successfully
    end

    def self.all_tracked_cards(sorting_options = {})
      cards = all.reject(&:no_tracking?)
      cards.sort_by!(&sorting_options[:sort_by].to_sym) if sorting_options[:sort_by]
      cards.reverse! if sorting_options[:order] == :desc
      return cards
    end

    def self.build_from(trello_card)
      trello_card_id = trello_card.id
      trello_card.attributes.delete(:id)
      new(trello_card.attributes.merge(trello_id: trello_card_id))
    end

    def self.efforts_between(search_options)
      condition = {}
      {'$gte' => :from_date, '$lte' => :to_date}.each do |selection, option_key|
        condition[selection] = search_options[option_key] if search_options[option_key]
      end

      where("efforts.date" => condition)
    end

    def status
      if done?
        :done
      elsif efforts.empty?
        :todo
      else
        :in_progress
      end
    end

    def add(tracking)
      tracking.add_to(self)
    end

    def add!(tracking)
      add(tracking) && save!
    end

    def contains_effort?(effort)
      efforts.unscoped.any? { |e| e.tracking_notification_id == effort.tracking_notification_id }
    end

    def contains_estimate?(estimate)
      estimates.any? { |e| e.tracking_notification_id == estimate.tracking_notification_id }
    end

    def no_tracking?
      first_activity_date.nil?
    end

    def first_activity_date
      [working_start_date, first_estimate_date].compact.min
    end

    def working_start_date
      efforts.sort_by(&:date).first.date if efforts.present?
    end

    def first_estimate_date
      estimates.sort_by(&:date).first.date if estimates.present?
    end

    def last_estimate_date
      estimates.sort_by(&:date).last.date if estimates.present?
    end

    def total_effort
      efforts.map(&:amount).inject(0, &:+)
    end

    def members
      efforts.map(&:members).flatten.uniq
    end

    def last_estimate_error
      estimate_errors.last
    end

    def estimate_errors
      return [] if estimates.empty? || efforts.empty?

      estimate_errors = []
      estimates.each do |each|
        estimate_errors << (100 * ((total_effort - each.amount) / each.amount * 1.0)).round(2)
      end

      estimate_errors
    end

    def trello_notifications
      # TODO select all efforts, even the muted ones?
      notification_ids = efforts.map(&:tracking_notification_id) | estimates.map(&:tracking_notification_id)
      notification_ids.map { |id| Trello::Notification.find(id) rescue nil }.compact.sort_by(&:date)
    end

    def to_s
      "[#{name}]. Total effort: #{total_effort}h. Estimates #{estimates.map(&:to_s)}. Efforts: #{efforts.map(&:to_s)}"
    end

    def ==(other)
      return true if other.equal?(self)
      return false unless other.kind_of?(self.class)
      trello_id == other.trello_id
    end

  end

end

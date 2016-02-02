class Badginator
  module Nominee

    def self.included(base)
      base.class_eval {
        def badges
          AwardedBadge.select('badge_code, MAX(level) as level').where(awardee_type: self.class, awardee_id: self.id).group(:awardee_id, :badge_code)
        end
      }
    end

    def try_award_badges(context = {})
      statuses = []
      Badginator.badges.each { |badge|
        status = self.try_award_badge(badge.code, context)
        if status.code == Badginator::WON
          statuses << status
        end
      }
      statuses
    end

    def try_award_badge(badge_name, context = {})
      badge = Badginator.get_badge(badge_name)
      success = badge.condition.present? ? badge.condition.call(self, context) : nil
      status_from_level success
    end

    def has_badge?(badge_code, level)
      AwardedBadge.find_by(badge_code: badge_code, level: level, awardee: self)
    end

    def status_from_level(level)
      case level
        when nil
          Badginator::Status(Badginator::DID_NOT_WIN)
        else
          if self.has_badge?(badge_name, level)
            Badginator::Status(Badginator::ALREADY_WON)
          else
            attributes = { awardee: self, badge_code: badge.code, level: level }
            attributes.merge! prepare_model_attributes context[:model]
            awarded_badge = AwardedBadge.create attributes
            Badginator::Status(Badginator::WON, awarded_badge)
          end
      end
    end

    private

    def prepare_model_attributes(model)
      model.present? ? { awardable_type: model.class, awardable_id: model.id } : {}
    end
  end
end

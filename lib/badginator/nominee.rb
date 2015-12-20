class Badginator
  module Nominee

    def self.included(base)
      base.class_eval {
        has_many :badges, class_name: "AwardedBadge", as: :awardee
      }
    end

    def try_award_badges(context)
      statuses = []
      Badginator.badges.each { |badge|
        status = self.try_award_badge(badge.name, context)
        if status.code == Badginator::WON
          statuses << status
        end
      }
      statuses
    end

    def try_award_badge(badge_name, context = {})
      badge = Badginator.get_badge(badge_name)
      success = badge.condition.call(self, context)
      status = nil
      case success
        when -1
          status = Badginator::Status(Badginator::DID_NOT_WIN)
        else
          if self.has_badge?(badge_name, success)
            status = Badginator::Status(Badginator::ALREADY_WON)
          else
            awarded_badge = AwardedBadge.create! awardee: self, badge_code: badge.code, level: success
            status = Badginator::Status(Badginator::WON, awarded_badge)
          end
      end

      status
    end

    def has_badge?(badge_code, level)
      AwardedBadge.where(badge_code: badge_code, level: level, awardee: self).first
    end
  end
end

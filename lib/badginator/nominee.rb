class Badginator
  module Nominee

    def self.included(base)
      base.class_eval {
        # has_many :badges, class_name: "AwardedBadge", as: :awardee, :group => 'level'
        # has_many :badges, class_name: "AwardedBadge", as: :awardee, :finder_sql => lambda{ "SELECT id, awardee_id, awardee_type, badge_code, MAX(level) as level FROM messages WHERE awardee_id=#{id} AND awardee_type = #{self}" }
        def badges
          AwardedBadge.select('awardee_id, badge_code, MAX(level) as level').where("awardee_id = #{id} AND awardee_type = '#{self.class}'").group('awardee_id, badge_code')
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
      success = badge.condition != nil ? badge.condition.call(self, context) : nil
      status = nil
      case success
        when nil
          status = Badginator::Status(Badginator::DID_NOT_WIN)
        else
          if self.has_badge?(badge_name, success)
            status = Badginator::Status(Badginator::ALREADY_WON)
          else
            awarded_badge = AwardedBadge.create awardee: self, badge_code: badge.code, level: success
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

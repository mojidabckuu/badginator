require 'singleton'
require "badginator/version"
require "badginator/badge"
require "badginator/status"
require "badginator/nominee"

class Badginator
  include Singleton

  class Configuration
    attr_accessor :default_badge_image
    attr_accessor :badges_image_prefix
    attr_accessor :badge_fields
    attr_accessor :fallback_image_name
    attr_accessor :fallback_image_ext

    def initialize
      @default_badge_image = 'assets/badges/default.png'
      @badge_fields = :code, :name, :title, :description, :condition, :disabled, :levels, :image, :reward, :category
      @fallback_image_name = false
      @badges_image_prefix = nil
      @fallback_image_ext = 'png'
    end
  end

  DID_NOT_WIN = 1
  WON         = 2
  ALREADY_WON = 3
  ERROR       = 4

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.reset
    @configuration = Configuration.new
  end

  def initialize
    @badges = {}
  end

  def get_badge(badge_code)
    @badges.fetch(badge_code)
  end

  def badges
    @badges.values.select { |badge| ! badge.disabled }
   end

  def self.badges
    self.instance.badges
  end

  def define_badge(*args, &block)
    badge = Badge.new
    badge.build_badge &block
    badge.freeze

    if @badges.key?(badge.code)
      raise "badge code '#{badge.code}' already defined."
    end

    @badges[badge.code] = badge
  end

  def self.define_badge(*args, &block)
    self.instance.define_badge(*args, &block)
  end

  def self.get_badge(badge_code)
    self.instance.get_badge(badge_code)
  end

  def self.Status(status_code, badge = nil)
    case status_code
      when DID_NOT_WIN, WON, ALREADY_WON, ERROR
        Badginator::Status.new code: status_code, badge: badge
      else
        rails TypeError, "Cannot convert #{status_code} to Status"
    end
  end

  Badge.setters Badginator.configuration.badge_fields
end

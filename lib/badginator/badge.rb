class Badginator
  class Badge

    def self.setters(*method_names)
      method_names.each do |name|
        send :define_method, name do |*data|
          if data.length > 0
            instance_variable_set "@#{name}", data.first
          else
            value = instance_variable_get "@#{name}"
            case name
              when :name, :title, :description
                return (value && value.is_a?(String)) ? I18n.t(value) : value
              when :image
                if value
                  if Badginator.configuration.badges_image_prefix
                    return "#{Badginator.configuration.badges_image_prefix}/#{value}"
                  end
                  return value
                end
                return Badginator.configuration.default_badge_image
            end
            return value
          end
        end
      end
    end

    setters :code, :name, :title, :description, :condition, :disabled, :levels, :image, :reward

    def build_badge(&block)
      instance_eval &block
      @code = @code.to_sym if @code
    end

  end
end

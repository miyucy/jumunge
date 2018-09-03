require "jumunge/version"

module Jumunge
  class JuValue
    def initialize(object, trail, trails)
      @object = object
      @trail  = trail
      @trails = trails
    end

    def perform
      @object[key_name] = empty_value unless @object.key? key_name
      @object
    end

    private

    def key_name
      @key_name ||= @trail[0..-2]
    end

    def empty_value
      nil
    end
  end

  class JuArray
    def initialize(object, trail, trails)
      @object = object
      @trail  = trail
      @trails = trails
    end

    def perform
      @object[key_name] = empty_value unless @object.key? key_name
      @object[key_name] = deep_applied_value if @trails.size.positive?
      @object
    end

    private

    def key_name
      @key_name ||= @trail[0..-3]
    end

    def empty_value
      []
    end

    def deep_applied_value
      @object[key_name].map do |value|
        Jumunge.new(value, remaining_trails).perform
      end
    end

    def remaining_trails
      @remaining_trails ||= @trails.join('.')
    end
  end

  class JuOther
    def initialize(object, trail, trails)
      @object = object
      @trail  = trail
      @trails = trails
    end

    def perform
      @object[key_name] = empty_value unless @object.key? key_name
      @object[key_name] = deep_applied_value if @trails.size.positive?
      @object
    end

    private

    def key_name
      @trail
    end

    def empty_value
      {}
    end

    def deep_applied_value
      Jumunge.new(@object[key_name], remaining_trails).perform
    end

    def remaining_trails
      @remaining_trails ||= @trails.join('.')
    end
  end

  class JuThru
    def initialize(object, *)
      @object = object
    end

    def perform
      @object
    end
  end

  class JuOpt
    def initialize(object, trail, trails)
      @object = object
      @trail  = trail
      @trails = trails
    end

    def perform
      if @object.key? key_name
        @object[key_name] = deep_applied_value
        @object
      else
        @object
      end
    end

    private

    def key_name
      @key_name ||= @trail[0..-2]
    end

    def deep_applied_value
      Jumunge.new(@object[key_name], remaining_trails).perform
    end

    def remaining_trails
      @remaining_trails ||= @trails.join('.')
    end
  end

  class Jumunge
    def initialize(object, path)
      @object = object
      @trail, *@trails = path.split '.'
      @is_array = @trail[-2..-1] == '[]'
      @is_value = @trail[-1] == '!'
      @is_opt = @trail[-1] == '?'
      @performer = performer_class.new @object, @trail, @trails
    end

    def perform
      @performer.perform
    end

    private

    def performer_class
      if @object
        if @is_array
          JuArray
        elsif @is_value
          JuValue
        elsif @is_opt
          JuOpt
        else
          JuOther
        end
      else
        JuThru
      end
    end
  end
  private_constant :Jumunge, :JuArray, :JuValue, :JuOther, :JuThru, :JuOpt

  def jumunge(object, *paths)
    paths.inject(object) do |result, path|
      Jumunge.new(result, path).perform
    end
  end
  module_function :jumunge
end

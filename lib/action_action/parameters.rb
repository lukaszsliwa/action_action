module ActionAction
  class Parameters
    def initialize(klass, params = {})
      @_klass, @params = klass, params
    end

    def perform(*args)
      @_klass.new(@params).perform_with_callbacks(*args)
    end

    def require(params = {})
      if (missing = params.keys.select { |key| params[key].nil? }).present?
        raise ActionAction::Error.new("Missing keys: #{missing.join(', ')}")
      end
      Parameters.new(@_klass, @params.merge(params))
    end
    alias_method :set!, :require
    alias_method :with!, :require
    alias_method :require!, :require

    def set(params = {})
      Parameters.new(@_klass, @params.merge(params))
    end
    alias_method :with, :set
  end
end

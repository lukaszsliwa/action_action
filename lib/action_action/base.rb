module ActionAction
  class Base
    include ActiveSupport::Callbacks
    define_callbacks :perform

    extend ActionAction::Callbacks
    include ActionAction::Statuses

    attr_reader :status, :message, :result, :params

    def initialize(params = {})
      @params = params
    end

    class << self
      alias_method :attributes, :attr_accessor

      def require(params = {})
        Parameters.new(self).require(params)
      end
      alias_method :set!, :require
      alias_method :with!, :require
      alias_method :require!, :require

      def set(params = {})
        Parameters.new(self, params).set(params)
      end
      alias_method :with, :set

      def perform(*args)
        new.perform_with_callbacks(*args)
      end

      def perform!(*args)
        if (context = perform(*args)).success?
          return context
        end
        raise ActionAction::Error.new(context.message)
      end
    end

    def perform(*args)
      perform_with_callbacks(*args)
    end

    def perform_without_callbacks(*args)
      @result = perform(*args)
      success! if @status.nil?
      @result
    end

    def perform_with_callbacks(*args)
      run_callbacks :perform do
        perform_without_callbacks(*args)
      end
      self
    end
  end
end

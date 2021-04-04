module ActionAction
  class Base
    include ActiveSupport::Callbacks
    define_callbacks :perform

    extend ActionAction::Callbacks
    include ActionAction::Statuses

    attr_reader :status, :message, :value

    class << self
      alias_method :attributes, :attr_accessor

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

    def perform_without_callbacks(*args)
      @value = perform(*args)
      success! if @status.nil?
      @value
    end

    def perform_with_callbacks(*args)
      run_callbacks :perform do
        perform_without_callbacks(*args)
      end
      self
    end
  end
end

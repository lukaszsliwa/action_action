module ActionAction
  module Callbacks
    def after_perform(method_name = nil, params = {}, &block)
      prepare_callback(:perform, :after, method_name, params, &block)
    end

    def before_perform(method_name = nil, params = {}, &block)
      prepare_callback(:perform, :before, method_name, params, &block)
    end

    def around_perform(method_name)
      set_callback(:perform, :around, method_name)
    end

    private

    def prepare_callback(on, what, method_name = nil, params = {}, &block)
      set_callback(on, what) do
        if params[:on] == :error && error? || \
          params[:on] == :success && success? || params[:on].nil?
          block_given? ? instance_eval(&block) : self.method(method_name).call
        end
      end
    end
  end
end

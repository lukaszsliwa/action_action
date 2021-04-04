module ActionAction
  module Statuses
    {
      ActionAction::Status::Success => %i(success succeed done correct ready active),
      ActionAction::Status::Error => %i(error failure fail invalid incorrect inactive)
    }.each do |key, values|
      values.each do |value|
        define_method(:"#{value}?") { @status == key }

        define_method(:"#{value}!") do |**args|
          @message, @status = args[:message], key
        end
      end
    end
  end
end

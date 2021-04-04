require 'active_support/dependencies/autoload'
require 'active_support/callbacks'

require 'action_action/version'
require 'action_action/status'
require 'action_action/statuses'
require 'action_action/callbacks'
require 'action_action/base'
require 'action_action/error'

#
# Examples
#
#   class MyAction < ActionAction::Base
#     after_perform :send_email, on: :success
#
#     def perform(email_address)
#
#     end
#
#     def send_email
#
#     end
#   end
#

module ActionAction
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Error
end

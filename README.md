
[![Gem Version](https://badge.fury.io/rb/action_action.svg)](https://badge.fury.io/rb/action_action)
[![License MIT](https://img.shields.io/github/license/lukaszsliwa/action_action)](https://github.com/lukaszsliwa/action_action/blob/main/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/lukaszsliwa/action_action)](https://github.com/lukaszsliwa/action_action/issues)

# ActionAction

Simpler way to build and use Service Objects in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'action_action', '~> 4.0.3'
```

And then execute:

    $ bundle install

## ActionAction example

```ruby
# app/actions/my_action.rb
class MyAction < ActionAction::Base
  after_perform :notify
  
  def perform
    # Your code here
  end
  
  def notify
    # after perform
  end
end

# app/controllers/my_controller.rb
class MyController < ApplicationController
  def create
    MyAction.set(user: current_user).perform
  end
end
```

or `perform!` to raise an error if occurred.

```ruby
# app/actions/my_action.rb
class MyAction < ActionAction::Base
  def perform
    # Your code here
    error!(message: 'Example error message')
  end
end

# app/controllers/my_controller.rb
class MyController < ApplicationController
  def create
    MyAction.perform! # it will raise ActionAction::Error
  end
end
```

## Demo

```ruby
# app/actions/create_user_action.rb
class CreateUser < ActionAction::Base
  attributes :user
  
  after_perform :send_email_on_success, on: :success
  
  def perform(company, params)
    self.user = company.users.build(params)
    if self.user.save
      success!
    else
      error!
    end
  end
  
  def send_email_on_success
    UserMailer.with(user: self.user).welcome.deliver_later
  end
end

# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def create
    context = CreateUser.perform(current_company, params_user)
    
    respond_to do |format|
      if context.success?
        format.html { redirect_to dashboard_path, notice: 'Welcome to our app' }
      else
        format.html { render action: :new } 
      end
    end
  end
  
  private
  
  def params_user
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
  
  def current_company
    @company ||= Company.find_by!(subdomain: request.subdomain)
  end
end
```

## Parameters

You can set a parameter using `set`, `with` or `require`.
`require` will raise an error if at least one parameter value is `nil`

```ruby
# app/actions/create_account.rb

class CreateAccount < ActionAction::Base
  after_perform :done, on: :success
  
  def perform
    @account, @user = params[:account], params[:user]
    @account = @user.accounts.build(params[:params])
    if @account.save
      success!
    else
      error!(message: @account.errors.full_messages)
    end
    @account
  end
  
  def done
    @user.user_accounts.create!(account: @account)
  end
end
```


```ruby
# app/controllers/accounts_controller.rb

class AccountsController < ApplicationController
  def new
    @account = Account.new  
  end
  
  def create
    context = CreateAccount.with(user: current_user, params: params_account).perform
    @account = context.result
    
    respond_to do |format|
      if context.success?
        format.html { redirect_to account_path(@account) }
      else
        format.html { render action: :new }
      end
    end
  end
  
  private
  
  def params_account
    params.require(:account).permit(:name, :subdomain)
  end
end
```

Alternatively, use `set!`, `with!` if you would like to check if all parameters are present.

## Callbacks

On `success` or `error`:
* `after_perform`
* `before_perform`
  
```ruby
# app/actions/create_post.rb
class CreatePost < ActionAction::Base
  before_perform do
    # run a code before perform within a block
  end
  
  after_perform do
    # run a code after perform within a block
  end
  
  after_perform :run_success_callback, on: :success
  after_perform :run_error_callback, on: :error
  
  def perform(user, params: {})
    @post = user.posts.build(params)
    
    if @post.save
      success!(message: 'Post was successfully created.')
    else
      error!(message: @post.errors.full_messages.join(' '))
    end
  end

  protected
  
  def run_success_callback
    PostMailer.with(post: @post).success.deliver_later
  end
  
  def run_error_callback
    PostMailer.with(post: @post).error.deliver_later
  end
end
```

* `around_perform`

```ruby
# app/actions/run_process.rb
class RunProcess < ActionAction::Base
  around_perform :measure
  
  def measure
    @start = Time.current
    yield
    @end = Time.current
  end
  
  def perform(id)
    `#{Process.find(id).command}`
  end
end
```

## Statuses

Call `success!`, `succeed!`, `done!`, `correct!`, `ready!`, `active!` if the action performed successfully or `error!`, `fail!`, `failure!`, `failed!`, `invalid!`, `incorrect!`, `inactive!` otherwise.

```ruby
# app/actions/run.rb
class Run < ActionAction::Base
  def perform
    if (@value = rand(100)) % 2 == 0
      success!
    else
      fail!
    end
  end
  
  after_perform :send_email_on_success
  
  def send_email_on_success
    RunnerMailer.set(value: @value).deliver_later if success?
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lukaszsliwa/action_action. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/lukaszsliwa/action_action/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActionAction project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/lukaszsliwa/action_action/blob/master/CODE_OF_CONDUCT.md).

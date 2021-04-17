RSpec.describe ActionAction::Base do
  class MyAction1 < ActionAction::Base
    before_perform :go!

    attr_reader :value

    def perform(company, params)
      success!(message: 'Done')
    end

    def go!
      @value = :won
    end
  end

  class MyAction2 < ActionAction::Base
    after_perform { @value = :done }

    attr_reader :value

    def perform(company, params)
    end
  end

  class MyAction3 < ActionAction::Base
    attr_reader :value

    after_perform { @value = :after }

    before_perform do
      go!
      @value = :before
    end

    def perform(company, params)
      @value = :perform
      error!(message: 'This is example error message')
    end

    def go!
      @value = :gone
    end
  end

  class MyAction4 < ActionAction::Base
    attr_accessor :value, :around_start, :around_end

    around_perform :around_perform

    def around_perform
      self.around_start = true
      yield
      self.around_end = true
    end

    def perform(company, params)
      success!
    end
  end

  class MyAction5 < ActionAction::Base
    attributes :value, :start, :end, :status

    def perform(company, params)
      success!
      self.value = :ok
    end
  end

  class MyAction6 < ActionAction::Base
    attributes :start, :end, :status, :value

    def perform(company, params)
      error!
    end
  end

  class MyAction7 < ActionAction::Base
    def perform(company, params)
    end
  end

  class MyAction8 < ActionAction::Base
    before_perform :go!

    attr_accessor :value

    def perform
      success!(message: 'Done')
    end

    def go!
      @value = { company: @company, param: params[:param]}
    end
  end

  describe '#success?' do
    it "should be a success" do
      expect(MyAction1.perform('MyCompany', { param: 1, xyz: 2 }).success?).to eq(true)
      expect(MyAction2.perform('MyCompany', { param: 1, xyz: 2 }).success?).to eq(true)
      expect(MyAction3.perform('MyCompany', { param: 1, xyz: 2 }).success?).to eq(false)
      expect(MyAction4.perform('MyCompany', { param: 1, xyz: 2 }).success?).to eq(true)
    end
  end

  describe '#error?' do
    it "should be a success" do
      expect(MyAction1.perform('MyCompany', { param: 1, xyz: 2 }).error?).to eq(false)
      expect(MyAction2.perform('MyCompany', { param: 1, xyz: 2 }).error?).to eq(false)
      expect(MyAction3.perform('MyCompany', { param: 1, xyz: 2 }).error?).to eq(true)
      expect(MyAction4.perform('MyCompany', { param: 1, xyz: 2 }).error?).to eq(false)
    end
  end

  describe '#perform' do
    it 'should perform and return error status' do
      expect(MyAction6.perform('MyCompany', { param: 1, xyz: 2 }).error?).to eq(true)
    end
  end

  describe '#perform!' do
    it 'should return instance' do
      expect(MyAction7.perform!('MyCompany', { param: 1, xyz: 2 }).success?).to eq(true)
    end

    it 'should raise ActionAction::Error' do
      expect {
        MyAction6.perform!('MyCompany', { param: 1, xyz: 2 })
      }.to raise_error(ActionAction::Error)
    end
  end

  describe 'callbacks' do
    it 'should set result to after' do
      action = MyAction3.perform('MyCompany', { param: 1, xyz: 2 })

      expect(action.success?).to eq(false)
      expect(action.value).to eq(:after)
    end

    describe 'before_perform' do
      let(:action) { MyAction1.perform('MyCompany', { param: 1, xyz: 2 }) }

      it 'should set result to :won' do
        expect(action.message).to eq('Done')
        expect(action.success?).to eq(true)
        expect(action.value).to eq(:won)
      end
    end

    describe 'after_perform' do
      let(:action) { MyAction2.perform('MyCompany', { param: 1, xyz: 2 }) }

      it 'should set result to :gone' do
        expect(action.success?).to eq(true)
        expect(action.value).to eq(:done)
      end
    end

    describe 'after_around' do
      let(:action) { MyAction4.perform('MyCompany', { param: 1, xyz: 2 }) }

      it 'should set result to :gone' do
        expect(action.success?).to eq(true)
        expect(action.around_start).to eq(true)
        expect(action.around_end).to eq(true)
      end
    end
  end

  describe '.set' do
    let(:action1) { MyAction8.set(company: 'MyCompany', param: 1).perform }
    let(:action2) { MyAction8.set(company: 'MyCompany', param: nil).perform }

    it 'should set variables and perform' do
      expect(action1.success?).to eq(true)
      expect(action1.value[:company]).to eq('MyCompany')
      expect(action1.value[:param]).to eq(1)
      expect(action1.params).to eq(company: 'MyCompany', param: 1)
      expect(action2.success?).to eq(true)
    end
  end

  describe '.set!' do
    let(:action1) { MyAction8.set!(company: 'MyCompany', param: 1).perform }
    let(:action2) { MyAction8.set!(company: 'MyCompany', param: nil).perform }

    it 'should set variables using set! and perform' do
      expect { action2}.to raise_error(ActionAction::Error)
      expect(action1.success?).to eq(true)
    end
  end

  describe '.with' do
    let(:action1) { MyAction8.with(company: 'MyCompany', param: 1).perform }
    let(:action2) { MyAction8.with(company: 'MyCompany', param: nil).perform }

    it 'should set variables using with and perform' do
      expect(action1.success?).to eq(true)
      expect(action1.value[:company]).to eq('MyCompany')
      expect(action1.value[:param]).to eq(1)
      expect(action1.params).to eq(company: 'MyCompany', param: 1)
      expect(action2.success?).to eq(true)
    end
  end

  describe '.with!' do
    let(:action1) { MyAction8.with!(company: 'MyCompany', param: nil).perform }
    let(:action2) { MyAction8.with!(company: 'MyCompany', param: 1).perform }

    it 'should set variables using with! and perform' do
      expect { action1 }.to raise_error(ActionAction::Error)
      expect(action2.success?).to eq(true)
    end
  end

  describe '.require' do
    let(:action1) { MyAction8.require(company: 'MyCompany', param: nil).perform }
    let(:action2) { MyAction8.require(company: 'MyCompany', param: 2).perform }

    it 'should require variables and perform' do
      expect { action1 }.to raise_error(ActionAction::Error)
      expect(action2.success?).to eq(true)
    end
  end

  describe 'set and require chain' do
    let(:action) { MyAction8.require(company: 'MyCompany').set(param1: 1).with(param2: 2).set().perform }

    it 'should perform an action with chain of sets' do
      expect(action.success?).to eq(true)
      expect(action.params[:param1]).to eq(1)
      expect(action.params[:param2]).to eq(2)
      expect(action.params[:company]).to eq('MyCompany')
    end
  end
end

RSpec.describe ActionAction::Base do
  class MyAction1 < ActionAction::Base
    before_perform :go!

    attr_reader :result

    def perform(company, params)
      success!(message: 'Done')
    end

    def go!
      @result = :won
    end
  end

  class MyAction2 < ActionAction::Base
    after_perform { @result = :done }

    attr_reader :result

    def perform(company, params)
    end
  end

  class MyAction3 < ActionAction::Base
    attr_reader :result

    after_perform { @result = :after }

    before_perform do
      go!
      @result = :before
    end

    def perform(company, params)
      @result = :perform
      error!(message: 'This is example error message')
    end

    def go!
      @result = :gone
    end
  end

  class MyAction4 < ActionAction::Base
    attr_accessor :result, :around_start, :around_end

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
    attributes :result, :start, :end, :status, :value

    def perform(company, params)
      success!
      self.result = :ok
    end
  end

  class MyAction6 < ActionAction::Base
    attributes :result, :start, :end, :status, :value

    def perform(company, params)
      error!
    end
  end

  class MyAction7 < ActionAction::Base
    def perform(company, params)
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
      expect(action.result).to eq(:after)
    end

    describe 'before_perform' do
      let(:action) { MyAction1.perform('MyCompany', { param: 1, xyz: 2 }) }

      it 'should set result to :won' do
        expect(action.message).to eq('Done')
        expect(action.success?).to eq(true)
        expect(action.result).to eq(:won)
      end
    end

    describe 'after_perform' do
      let(:action) { MyAction2.perform('MyCompany', { param: 1, xyz: 2 }) }

      it 'should set result to :gone' do
        expect(action.success?).to eq(true)
        expect(action.result).to eq(:done)
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
end

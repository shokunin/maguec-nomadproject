require 'spec_helper'
describe 'nomadproject' do

  context 'with defaults for all parameters' do
    it { should contain_class('nomadproject') }
  end
end

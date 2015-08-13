require 'spec_helper'

describe CountryController do
  context 'country feed' do
    let(:feed) { :country }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:user) { random_id }
      let(:feed_key) { 'countries' }
      it_behaves_like 'a successful feed'
    end
  end
end

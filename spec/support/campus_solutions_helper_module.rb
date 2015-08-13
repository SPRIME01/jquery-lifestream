module CampusSolutionsHelperModule

  shared_examples 'a simple proxy that returns errors' do
    before {
      proxy.set_response(status: 506, body: '')
    }
    it 'returns errors properly' do
      expect(subject[:errored]).to eq true
    end
  end

  shared_examples 'an unauthenticated user' do
    it 'returns 401' do
      get feed
      expect(response.status).to eq 401
      expect(response.body.strip).to eq ''
    end
  end

  shared_examples 'a successful feed' do
    it 'has some data' do
      session['user_id'] = user
      get feed
      json = JSON.parse(response.body)
      expect(json['statusCode']).to eq 200
      expect(json['feed'][feed_key]).to be
    end
  end

end

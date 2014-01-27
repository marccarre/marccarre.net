require 'spec_helper'

describe 'routes for homepage' do
  it 'routes /articles to homepage#articles' do
    expect(get('/articles')).to route_to('homepage#articles')
    expect(post('/articles')).not_to be_routable
    expect(put('/articles')).not_to be_routable
    expect(delete('/articles')).not_to be_routable
  end
end
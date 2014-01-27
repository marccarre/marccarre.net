MarccarreNet::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  root to: redirect('articles')

  scope '(:locale)' do
    get 'articles', to: 'homepage#articles'
    get 'projects', to: 'homepage#projects'
    get 'about',    to: 'homepage#about'
  end
end

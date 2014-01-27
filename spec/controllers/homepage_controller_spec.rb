require 'spec_helper'
require 'homepage_controller'

describe HomepageController do
  context 'with render_views' do
    render_views

    describe 'GET /articles' do
      it 'renders articles in English by default' do
        get :articles
        expect(response).to render_template('articles')
        expect(response.body).to match /Coming soon/m
      end

      it 'renders articles in English if provided with an incompatible locale' do
        request.headers['Accept-Language'] = 'de'
        get :articles
        expect(response).to render_template('articles')
        expect(response.body).to match /Coming soon/m
      end

      it 'renders articles in English if en is provided' do
        request.headers['Accept-Language'] = 'en'
        get :articles
        expect(response).to render_template('articles')
        expect(response.body).to match /Coming soon/m
      end

      it 'renders articles in English if en-US,en;q=0.8 is provided' do
        request.headers['Accept-Language'] = 'en-US,en;q=0.8'
        get :articles
        expect(response).to render_template('articles')
        expect(response.body).to match /Coming soon/m
      end

      it 'renders articles in English if en-GR,en;q=0.8 is provided' do
        request.headers['Accept-Language'] = 'en-GR,en;q=0.8'
        get :articles
        expect(response).to render_template('articles')
        expect(response.body).to match /Coming soon/m
      end

      it 'renders articles in French if fr-FR,fr;q=0.8 is provided' do
        request.headers['Accept-Language'] = 'fr-FR,fr;q=0.8'
        get :articles
        expect(response).to render_template('articles')
        expect(response.body).to match /En construction/m
      end

      it 'renders articles in French if fr-FR;q=0.8 is provided' do
        request.headers['Accept-Language'] = 'fr-FR;q=0.8'
        get :articles
        expect(response).to render_template('articles')
        expect(response.body).to match /En construction/m
      end

      it 'renders articles in French if fr is provided' do
        request.headers['Accept-Language'] = 'fr'
        get :articles
        expect(response).to render_template('articles')
        expect(response.body).to match /En construction/m
      end

      it 'renders articles in French when provided with fr as a parameter, and persists this value for later requests' do
        get :articles, {locale: :fr}
        expect(response).to render_template('articles')
        expect(response.body).to match /En construction/m

        request.headers['Accept-Language'] = 'en-GR,en;q=0.8'
        get :articles
        expect(response).to render_template('articles')
        expect(response.body).to match /En construction/m
      end
    end
  end 
end
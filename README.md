marccarre.com / marccarre.github.io
===================================

[![Build Status](https://travis-ci.org/marccarre/marccarre.github.io.svg?branch=master)](https://travis-ci.org/marccarre/marccarre.github.io)

Personal website:
* built with Jekyll (`bundle exec jekyll serve --config=_config.yml,_config_cit.yml` to run locally)
* no Jekyll plugin
* responsive design based on Boostrap
* gracefully degrades if Javascript and fonts are disabled
* support for multiple languages / i18n
* lists GitHub projects
* comments powered by Disqus
* compressed CSS
* compressed HTML (using [jekyll-compress-html](https://github.com/penibelst/jekyll-compress-html))

URL: [https://www.marccarre.com](https://www.marccarre.com) / [https://marccarre.github.io](https://marccarre.github.io)

## Development

- [Install `ruby` and `jekyll`.](https://jekyllrb.com/docs/installation/macos/)
- Run:
  ```console
  $ bundle install
  $ bundle exec jekyll -v
  jekyll 3.8.5
  $ bundle exec jekyll serve --config=_config.yml,_config_cit.yml
  ```

---
# Showcase GitHub projects (JavaScript/jQuery).
# Potential alternatives: 
# - https://github.com/akshaykumar6/github-js
# - https://github.com/zenorocha/jquery-github
---
$ ->
  $('#github-projects').html('<span class="text-muted">{{ site.data.translations[page.lang].github_load }}</span>');
  
  reposData = {}

  blackList = {}
  blackList[name] = null for name in ["{{ site.github_blacklist | join: '","'}}"]


  extractSourceRepoDetails = (repo) ->
    fields = extractRepoDetails(repo)
    previous = reposData[repo.name]
    fields.is_fork   = previous.is_fork
    fields.html_url  = previous.html_url
    return fields


  extractRepoDetails = (repo) ->
    fields =
      name:              repo.name
      html_url:          repo.html_url
      is_fork:           repo.fork  # Used for rendering
      fork:              repo.fork  # Used to pull source repository
      description:       repo.description
      language:          repo.language
      pushed_at:         new Date(repo.pushed_at)
      default_branch:    repo.default_branch
      watchers_count:    repo.watchers_count
      forks_count:       repo.forks_count
      open_issues_count: repo.open_issues_count
      stargazers_count:  repo.stargazers_count
      activity_score:    repo.watchers_count + repo.forks_count + repo.open_issues_count + repo.stargazers_count
    return fields


  extractReposDetails = (repos) ->
    return (extractRepoDetails(repo) for repo in repos when not blackList.hasOwnProperty repo.name)


  findUrlForNextPage = (meta) ->
    if not meta? or not meta.Link?
      console.log('No more repositories to load: something went wrong! Meta: ' + JSON.stringify(meta))
      return null
    for link in meta.Link
      [url, { rel }] = link
      if rel == 'next'
        console.log('More repositories to load.')
        return url
    console.log('No more repositories to load. All done.')
    return null


  containsForkedRepo = (reposData) ->
    for key of reposData
      if reposData[key].fork
        return true
    return false


  values = (dict) ->
    array = []
    array.push dict[key] for key of dict
    return array


  render = (repo) ->
    return '<div class="col-lg-4 col-md-4 col-sm-6 col-xs-12">
                <div class="panel panel-default">
                  <div class="panel-body">
                    <div class="github-project-name"><a href="' + repo.html_url+ '">' + repo.name + '</a></div>
                    <div class="github-project-description clearfix">' + repo.description + '</div>
                    <div class="github-project-activity"> 
                      ' + (if repo.language? then '<span class="badge" title="Language">' + repo.language + '</span> ' else ' ') + '
                      <span class="badge" title="Watchers">' + repo.watchers_count + ' <span class="octicon octicon-eye"></span></span>
                      <span class="badge" title="Starred">' + repo.stargazers_count + ' <span class="octicon octicon-star"></span></span>
                      <span class="badge" title="Forked">' + repo.forks_count + ' <span class="octicon octicon-repo-forked"></span></span> 
                      <span class="badge" title="Opened issues">' + repo.open_issues_count + ' <span class="octicon octicon-issue-opened"></span></span> 
                      <div><small>Latest commit to <b>' + repo.default_branch + '</b> on: ' + repo.pushed_at.toLocaleDateString() + '</small></div>
                    </div>
                  </div>
                </div>
              </div>'


  adjustHeights = () ->
    $('div.github-project-description').height('auto')
    maxHeight = Math.max.apply(null, $('div.github-project-description').map(() -> return $(this).height()).get())
    $('div.github-project-description').height(maxHeight)
    console.log('Re-adjusted height of GitHub projects.')


  $(window).resize () -> adjustHeights()


  renderAll = (reposDict) ->
    repos = values(reposDict)
    repos.sort (a, b) -> 
      activity_score = b.activity_score - a.activity_score  # Sort by activity in decreasing order
      return if activity_score == 0 then b.pushed_at > a.pushed_at else activity_score
    dom = ['<div class="row">']
    dom.push render(repo) for repo in repos
    dom.push '</div>'
    $('#github-projects').html(dom.join(''))
    adjustHeights()
    

  typeIsArray = (o) ->
    return Object::toString.call(o) == '[object Array]'


  onSuccess = (response) ->
    switch (response.meta.status)
      when 200
        if typeIsArray(response.data)
          console.log('Successfully loaded ' + response.data.length + ' GitHub repositorie(s).')
          reposData[repoData.name] = repoData for repoData in extractReposDetails(response.data)
          nextPage = findUrlForNextPage(response.meta)
          if nextPage? 
            getRepositories(nextPage)
          else if containsForkedRepo(reposData)
            getSourceRepoData(name) for name of reposData when reposData[name].fork
          else
            renderAll(reposData)
        else
          console.log('Successfully loaded GitHub source repository for "' + response.data.name + '".')
          reposData[response.data.name] = extractSourceRepoDetails(response.data.source)
          if !containsForkedRepo(reposData)
            renderAll(reposData)
      when 403
        console.log('Failed to load GitHub repositories: ' + response.data.message)
        $('#github-projects').html('<span class="text-warning">[' + response.data.message + ']</span>')
      else
        console.log('Failed to load GitHub repositories: ' + JSON.stringify(response.meta) + '.')
        $('#github-projects').html('<span class="text-danger">[{{ site.data.translations[page.lang].github_error }}]</span>')


  onError = (jqxhr, message, error) ->
    console.log('Failed to load GitHub repositories: ' + message + ' -- ' + error + '.')
    $('#github-projects').html('<span class="text-danger">[{{ site.data.translations[page.lang].github_error }}]</span>')


  getSourceRepoData = (name) ->
    url = 'https://api.github.com/repos/{{ site.github_username }}/' + name
    console.log('Loading GitHub source repository for "' + name + '": ' + url)
    $.ajax
      url: url
      accepts: 'application/vnd.github.v3+json'
      dataType: 'jsonp'  
      success: onSuccess
      error: onError  


  getRepositories = (url) ->
    console.log('Loading GitHub repositories: ' + url)
    $.ajax
      url: url
      accepts: 'application/vnd.github.v3+json'
      dataType: 'jsonp'
      success: onSuccess
      error: onError


  getRepositories('https://api.github.com/users/{{ site.github_username }}/repos')

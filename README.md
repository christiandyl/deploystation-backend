# Project description
This is backend part of [DeployStation] project.

# How to

## Code
* please use only soft tabs with two space size;

## Setup development env
```
  # clone repo
  $ git clone git@bitbucket.org:christiandyl/christiandyl-deploystation-backend.git
  # enter the project folder
  $ cd christiandyl-deploystation-backend
  # install missing gems
  $ bundle install
  # create postgres database (in some cases you should use psql)
  $ bundle exec rake db:create
  # migrate database migrations
  $ bundle exec rake db:migrate
```

## Work with [Sidekiq]
* To launch sidekiq: `$ bundle exec sidekiq`.
* To see sidekiq logs: `$ tail -f logs/sidekiq.log`

## Launch [Rspec] tests
* to launch tests: `$ bundle exec rspec`

## Read [Rdoc] documentation
* to generate rdoc: `$ bundle exec yardoc --plugin rest --title "DeployStation backend API" --readme "README.md" --output-dir ./public/docs`
* to see generated docs `$ open public/docs/index.html`, or open manually using UI.

***Some specs need to have docker launched, so don't forget to install docker!!!***

## API FAQ
* Question: What headers should I sent in http request when I logged in?
* Answer: { "X-Auth-Token": "access_token" }

[DeployStation]:http://www.deploystation.com
[Sidekiq]:http://sidekiq.org/
[Rspec]:https://github.com/rspec
[Rdoc]:http://docs.seattlerb.org/rdoc/
# README

For local test I will provide master key in email.

`bin/setup` should be enough to setup the project.

## Some notes:
- tried to do separate commits in case one might follow process
- used scaffold for fast prototyping
- nice that Rails 8 has Github actions integration out of box!
- usually use rspec but since rails scaffold uses minitest, I used it

## Steps of project:

- [x] Create basic app
- [x] Create ColdEmail and gpt generator
- [x] Refactor controller to use form
- [x] Add response on same page with turbo
- [x] Add loader for generating


## Todos:
- [] store generation params for future purposes (maybe we want to regenerate for example)
- [] Add sidebar with links to other email for nicer navigation
- [] Use response streaming
- [] Use background job for email generation
- [] Falcon will be a good choice for such app (if generation will be in background jobs)
- [] Add tests

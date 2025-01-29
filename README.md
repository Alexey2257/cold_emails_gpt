# README

For local test I will provide master key in email

## Some notes:
- used scaffold for fast prototyping
- nice that Rails 8 has Github actions integration out of box!
- usually use rspec but since rails scaffold uses minitest, I used it

## Steps of project:

- [x] Create basic app
- [x] Create ColdEmail and basic generator
- [x] Refactor controller to use form
- [x] Add response on same page with turbo
- [x] Add loader for generating

## Todos:
- [] Add regeneration of existing email, store generation params for this purpose
- [] Add sidebar with links to other email
- [] Use response streaming
- [] Use background job for email generation
- [] Falcon will be a good choice for such app (if generation will be in background jobs)
- [] Add tests

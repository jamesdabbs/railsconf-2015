# Processes & Threads
## Resque vs. Sidekiq

Notes and material from my RailsConf 2015 talk. See `slides.md` for the (Deckset) slides.

### Running Locally

You care about the following commands:

```
$ ./q (resque|sidekiq) <JobName> [job args] # enqueue a job
$ rake resque:work # start a Resque worker
$ rake resque:pool # start a pool of Resque workers (see resque-pool.yml)
$ WORKERS=n rake sidekiq:work # start a number of Sidekiq workers
```

The available jobs are in `jobs.rb` and both Resque and Sidekiq compatible (which is probably a terrible idea).

There is also a simple rack app, available via `rackup`, for inspecting Resque, Sidekiq, and Redis in a web UI (at `/resque`, `/sidekiq` and `/redis`, respectively).

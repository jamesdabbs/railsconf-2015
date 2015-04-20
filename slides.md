# [fit] Processes & Threads
# [fit] _**Resque vs Sidekiq**_
# [fit] **@jamesdabbs | james@theironyard.com**

![](http://upload.wikimedia.org/wikipedia/commons/a/a7/Atlanta_Skyline_from_Buckhead.jpg)

---

^ Our goal: learn about concurrency by reading two of the classics - Resque and Sidekiq

# Read, read, read. Read everything – trash, classics, good and bad, and see how they do it.
— William Faulkner, on writing

![Faulkner, reading](http://sheimagazine.com/wp-content/uploads/2014/01/69eecb475a762e6c_large.jpeg)

---

# Background Workers

![inline fit](http://i.imgur.com/clKM5c2.png)


---

^ See https://github.com/blog/542-introducing-resque
^ and https://github.com/resque/resque/tree/1-x-stable#forking
^
^ Note: our code samples will be from the 1-x branch, which is a little old
^ and crufty relative to the coming 2.0 release

# Resque

Developed [at Github, ca. 2009](https://github.com/blog/542-introducing-resque)

* Let Redis handle the hard queue problems
* Let Resque focus on reliability, visibility, stats and responsiveness

---

# Resque —
# [fit] How?

---

# `fork(2)`

![A fork](http://king9int.com/source/products/0_20150130061504.jpg)

---

# Forking

```ruby
def log(str); puts "#{Process.pid}: #{str}"; end

a = 1
if pid = fork
  log "Waiting on child"
  Process.wait pid
  log "Done with fork. a=#{a}"
else
  log "Child doing work"
  sleep 1
  a += 1
  log "a=#{a}"
  exit
end
```

---

# Forking

Produces (modulo different `pid`s)

```bash
57388: Waiting on child
57416: Child doing work
57416: a=2
57388: Done with fork. a=1
```

---

^ https://www.facebook.com/atul016/posts/10202431507181143

# Forking

The child process

* springs into existence
* performs its job
* dies

![Meeseeks](http://i.imgur.com/N6LJUOb.jpg)

---

^ Step through an enqueue call and in to Redis
^ Queue up a pry job and explore the stack
^ Not concurrent - enqueue 3 tick jobs
^ resque-pool - 3 workers
^ See pstree | grep resque

# Resque —
# [fit] How?

---

# Resque, distilled

```ruby
start # Initialize, register signal handlers, &c.
loop do
  if job = redis_job_queue.pop
    child = fork do
      job.process
    end
    Process.wait child
  else
    sleep polling_frequency
  end
end
shutdown # Unregister signal handlers, &c.
```

---

# Resque —
# [fit] Why?

---

^ "Jobs will lock up, run too long, or have unwanted memory growth"

> Assume chaos
-- [— Resque](https://github.com/resque/resque/blob/68b43a3a01006abb0aabf0d564967f546ec1e134/README.markdown#forking)

![Chaos](http://i.imgur.com/zfWflMH.jpg)

---

^ Key point: forked threads have their own memory space
^ but get a copy (on write) of their parent's memory

# Forking

* mitigates the risk of leaking memory
* avoids the cost of booting Rails for each job
* allows using signals to e.g. shut down hung jobs

---

^ Forking workers isolates memory, which has upsides, but means that n concurrent workers
^ require n times as much memory

# Sidekiq —
# [fit] Why?

![A challenger approaches](http://img4.wikia.nocookie.net/__cb20130201000028/ssb/images/6/6f/Challenger_Approaching_Luigi.png)

---

^ https://github.com/mperham/sidekiq/wiki/Why-Sidekiq

# Sidekiq

By [@mperham](https://twitter.com/mperham), ca. 2012

* "What if one process could do the work of 20 Resque processes?"
* Performance, simplicity, support
* Batteries included (failure retry, scheduled jobs, middleware)

---

# Sidekiq —
# [fit] How?

---

# Thread[^1]

[^1]: actually, [`pthread_create(3)`](http://linux.die.net/man/3/pthread_create)

![A thread](http://thehairdresserseyes.com/wp-content/uploads/2015/02/Thread1.jpg)

---

^ Other cons: the GIL

# [fit] Threads
# [fit] Pros: shared memory
# [fit] Cons: shared memory

---

^ Easy to write
^ Hard to reproduce, and thus hard to debug

# Race Conditions

```ruby
@wallet = 100
Thread.new { @wallet += 10 }
Thread.new { @wallet -= 10 }
```

---

# Race Conditions

```ruby
@wallet = 100
Thread.new do
  tmp = @wallet
  sleep rand(0..5)
  @wallet = tmp + 10
end
Thread.new do
  sleep rand(0..5)
  tmp = @wallet
  @wallet = tmp - 10
end
```

---

# [fit] Actors &
# [fit] Celluloid

![](http://learnyousomeerlang.com/static/img/erlang-the-movie.png)

---

```ruby
class Wallet
  include Celluloid
  attr_reader :amount

  def initialize; @amount  = 100; end
  def adjust(Δ) ; @amount += Δ  ; end
end

@wallet = Wallet.new 100
[10, -10].each { |Δ| wallet.async.adjust(Δ) }
@wallet.amount # => 100

```

---

# Celluloid - Async

```ruby
@wallet.async.adjust(Δ)
```

![inline](http://i.imgur.com/yeZ7its.png)

<sub>Diagram adapted from [T. Arcieri's "The Celluloid Ecosystem"](https://www.youtube.com/watch?v=ZVU7yRoYb3o)</sub>

---

# Celluloid - Sync

```ruby
@wallet.amount()
```

![inline](http://i.imgur.com/zmnxANM.png)

<sub>Diagram adapted from [T. Arcieri's "The Celluloid Ecosystem"](https://www.youtube.com/watch?v=ZVU7yRoYb3o)</sub>

---

# Sidekiq —
# [fit] How?

---

^ Subtler considerations: parallelism, MRI and the GIL ...

# Takeaways

* If you're memory-constrained, use Sidekiq
* If you're worried about thread safety, use Resque
* If you're both, ¯\\_(ツ)\_/¯
* If you're neither, be glad you're not both

---

# Takeaways

Don't be afraid to dive in to code

* `pry` and friends - `pry-stack_explorer`, `pry-byebug`, `pry-rescue`, etc.
* `bundle show`
* `ack --rb`

---

# Further Reading

Crack open a good gem

* [Unicorn](https://github.com/defunkt/unicorn)
* [resque-pool](https://github.com/nevans/resque-pool)
* [Adhearson](https://github.com/adhearsion/adhearsion)

---

# Further Reading

* These slides - [jamesdabbs/railsconf-2015](https://github.com/jamesdabbs/railsconf-2015/slides.md)
* T. Ball - [Unicorn Unix Magic Tricks](http://thorstenball.com/blog/2014/11/20/unicorn-unix-magic-tricks/)
* J. Storimer - [Understanding the GIL](http://www.jstorimer.com/blogs/workingwithcode/8085491-nobody-understands-the-gil)
* J. Lane - [Writing thread-safe Rails](https://bearmetal.eu/theden/how-do-i-know-whether-my-rails-app-is-thread-safe-or-not/)

---

# [fit] Processes & Threads
# [fit] _**Resque vs Sidekiq**_
# [fit] **@jamesdabbs | james@theironyard.com**

![](http://upload.wikimedia.org/wikipedia/commons/a/a7/Atlanta_Skyline_from_Buckhead.jpg)

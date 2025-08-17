require "tty-cursor"
require "io/console"
require "rainbow"

PHILOSOPHER_COUNT = 5

class Philosopher
  attr_reader :state, :eating_time

  def initialize(id, left, right)
    @id = id
    @left = left
    @right = right
    @state = :thinking
    @eating_time = 0.0
    @eating_start = nil
  end

  def to_s
    str = Rainbow("P#{@id}").color(color)
    case @state
    in :thinking then str.strike
    in :has_left then str.underline
    in :has_both then str.underline.bright
    in :eating then str.inverse
    end
  end

  def state_description
    case @state
    in :thinking then "is thinking"
    in :has_left then "has the left chopstick"
    in :has_both then "has both chopsticks"
    in :eating then Rainbow("is EATING").bright
    end
  end

  def color = @id + 1

  def eat!
    if @left.try_lock(self)
      @state = :has_left
      sleep(0.2) # Pause after picking up left chopstick

      if @right.try_lock(self)
        @state = :has_both
        sleep(0.2) # Pause after picking up right chopstick
        @state = :eating
        @eating_start = Time.now
        eating_duration = 2 + rand(3)
        sleep(eating_duration) # Eat for 2-5 seconds
        @eating_time += eating_duration
        @eating_start = nil
        @right.unlock
      end

      @left.unlock
    end

    @state = :thinking
    sleep(0.5 + rand(1)) # Think for 0.5-1.5 seconds before trying again
  end

  def current_eating_time
    if @eating_start
      @eating_time + (Time.now - @eating_start)
    else
      @eating_time
    end
  end
end

class Chopstick
  attr_reader :id

  def initialize(id)
    @id = id
    @mutex = Thread::Mutex.new
    @held_by = nil
  end

  def try_lock(p) = @mutex.try_lock && @held_by = p

  def unlock = @mutex.unlock && @held_by = nil

  def to_s = Rainbow("C#{@id}").color(color)

  def color = @held_by&.color || :white
end

chopsticks = PHILOSOPHER_COUNT.times
  .each_with_index
  .map { |i| Chopstick.new(i) }

philosophers = chopsticks
  .cycle
  .take(PHILOSOPHER_COUNT + 1)
  .each_cons(2)
  .map { |c1, c2| Philosopher.new(c1.id, c1, c2) }

threads = philosophers.map do |p|
  Thread.new do |t|
    loop do
      p.eat!
    end
  end
end

cursor = TTY::Cursor
print cursor.hide

begin
  loop do
    print cursor.clear_screen
    print cursor.move_to(0, 0)
  
    puts "Dining Table:"
    puts chopsticks.zip(philosophers).flatten.push(chopsticks[0]).join(" - ")
    
    puts "\nPhilosopher States:"
    philosophers.each do |p|
      timer = sprintf("%.1fs", p.current_eating_time)
      puts "  #{p}: #{p.state_description} (eating time: #{timer})"
    end
    
    sleep 0.05
  end
ensure
  print cursor.clear_screen
  print cursor.show
  threads.each(&:kill)
end

require 'parallel'

enum = (1...10000).each_slice(20)

yielder = lambda do
  begin
    sleep rand(1000) * 0.001
    enum.next.compact
  rescue StopIteration
    Parallel::Stop
  end
end

Parallel.each(yielder,
              in_threads: 8,
              finish: ->(batch, _, _) { update(last_indexed_count: (count += batch.length)) }) do |batch|
  puts batch.inspect
end
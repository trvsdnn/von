module Von
  module Counters
    module Commands
      def hget(*args)
        Von.connection.hget(*args)
      end
      
      def hgetall(*args)
        Von.connection.hgetall(*args)
      end
      
      def hincrby(*args)
        Von.connection.hincrby(*args)
      end      
      
      def hset(*args)
        Von.connection.hset(*args)
      end
      
      def lrange(*args)
        Von.connection.lrange(*args)
      end
      
      def rpush(*args)
        Von.connection.rpush(*args)
      end
      
      def llen(*args)
        Von.connection.llen(*args)
      end
      
      def lpop(*args)
        Von.connection.lpop(*args)
      end
      
      def hdel(*args)
        Von.connection.hdel(*args)
      end
    end
  end
end
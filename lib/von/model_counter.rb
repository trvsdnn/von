module Von
  module ModelCounter
    extend ::ActiveSupport::Concern

     module ClassMethods
       def increments_stat(key, options = {})
          increment_method = "increment_stat_#{key.gsub(/:/, '_')}".to_sym

          define_method increment_method do
            Von.increment(key)
          end

          case options[:on]
          when :create
            after_create increment_method
          when :save
            after_save increment_method
          when :update
            after_update increment_method
          else
            # default to create
            after_create increment_method
          end
       end
     end

  end
end
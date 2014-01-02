module MultipleMan
  class ModelSubscriber

    @subscriptions = []
    class << self
      attr_accessor :subscriptions

      def register(klass)
        self.subscriptions << new(klass)
      end
    end

    def initialize(klass)
      self.klass = klass
    end

    attr_reader :klass    

    def create(data)
      model = find_model(data)
      model.remote_id = data.delete(:id)
      model.attributes = data
      model.save!
    end

    alias_method :update, :create

    def destroy(data)
      model = find_model(data)
      model.destroy!
    end

    def routing_key
      RoutingKey.new(klass).to_s
    end

    def queue_name
      "#{MultipleMan.configuration.app_name}.#{klass.name}"
    end

  private

    def find_model(data)
      klass.find_by_remote_id(data[:id]) || klass.new
    end

    attr_writer :klass

  end
end
module Publishable
  class Engine < ::Rails::Engine

    initializer 'publishable.initialize' do
      ActiveSupport.on_load(:active_record) do
        extend Publishable::Macros
      end
    end

  end
end
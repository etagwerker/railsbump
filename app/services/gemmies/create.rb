require 'gems'

module Gemmies
  class Create < Services::Base
    class AlreadyExists < Error
      attr_reader :gemmy

      def initialize(gemmy)
        super nil

        @gemmy = gemmy
      end
    end

    def call(name)
      if name.blank?
        raise Error, 'Name is blank.'
      end

      if existing_gemmy = Gemmy.find_by(name: name)
        raise AlreadyExists.new(existing_gemmy)
      end

      begin
        Gems.info name
      rescue Gems::NotFound
        raise Error, 'Gem does not exist.'
      end

      gemmy = Gemmy.create!(name: name)

      AddWebhook.call_async gemmy
      Process.call_async gemmy

      gemmy
    end
  end
end

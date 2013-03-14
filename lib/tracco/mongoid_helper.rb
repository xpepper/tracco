module Tracco
  module MongoidHelper

    def without_mongo_raising_errors(&block)
      original_value = Mongoid.raise_not_found_error
      Mongoid.raise_not_found_error = false
      begin
        block.call if block
      ensure
        Mongoid.raise_not_found_error = original_value
      end
    end

  end
end

module Oink
  class RackLog < Log

    def default_metadata
      super + %w[controller_name action_name uri http_method response_code]
    end

  end
end
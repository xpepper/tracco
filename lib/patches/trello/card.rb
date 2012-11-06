module Trello

  class Card

    def estimates
      @estimates ||= []
    end

    def efforts
      @efforts ||= []
    end

    def total_effort
      efforts.map(&:amount).inject(0, &:+)
    end
    
    def to_s
      "[#{name}]. Total effort: #{total_effort}h. Estimates #{estimates.inspect}. Efforts: #{efforts.inspect}"
    end

  end

end

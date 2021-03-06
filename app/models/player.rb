class Player < ActiveRecord::Base
    GAME_RESULT = {
        WON: 1,
        DRAWN: 0,
        LOST: -1
    }

    has_many :host_games, class_name: "Game", foreign_key: "player1id"
    has_many :guest_games, class_name: "Game", foreign_key: "player2id"
    
    def games
        (host_games.to_a | guest_games.to_a).sort_by &:created_at
    end
    
    def elo_data_by_event
        data = []
        Event.all.sort_by(&:id).each do |e|
            data << [e.name, eval(e.elos)[self.id]]
        end
        data
    end

    GAME_RESULT.keys.each do |const_name|
      define_method ("#{const_name.downcase}_games") {
        host_games.where(result: GAME_RESULT[const_name]) | guest_games.where(result: -GAME_RESULT[const_name])
      }
    end
end

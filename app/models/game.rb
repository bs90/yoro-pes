require 'csv'
class Game < ActiveRecord::Base
    belongs_to :player1, class_name: "Player", foreign_key: "player1id"
    belongs_to :player2, class_name: "Player", foreign_key: "player2id"
    belongs_to :team1, class_name: "Team", foreign_key: "team1id"
    belongs_to :team2, class_name: "Team", foreign_key: "team2id"
    belongs_to :tournament
    after_create :set_belo_and_aelo_and_result
    
    TEAMS = {"bayern"=>1, "real"=>2, "barca"=>3, "psg"=>4, "manc"=>5, "chelsea"=>6, "juve"=>7, "arsenal"=>8, "dortmund"=>9, "manu"=>10, "atletico"=>11, "roma"=>12, "everton"=>13, "liverpool"=>14, "milan"=>15, "inter"=>16, "napoli"=>17, "lazio"=>18, "spurs"=>19, "argentina"=>20, "brazil"=>21, "colombia"=>22, "uruguay"=>23, "chile"=>24, "spain"=>25, "belgium"=>26, "switzerland"=>27, "germany"=>28, "england"=>29, "france"=>30, "croatia"=>31, "italy"=>32, "netherlands"=>33, "portugal"=>34, "sweden"=>35, "wales"=>36, "japan"=>37, "russia"=>38, "poland"=>39, "porto"=>40} 
    class << self
      def batch_create! tournament_id, filepath
        CSV.foreach(filepath) do |row|
          if row[0] == "no"
            next
          end
          @game = self.create player1id: Player.find_by_name(row[2]).id, player2id: Player.find_by_name(row[4]).id,
            team1id: TEAMS[row[6].downcase], team2id: TEAMS[row[7].downcase], 
            player1goal: row.last.first.to_i, player2goal: row.last.last.to_i, tournament_id: tournament_id, game_type: row[1]
        end
      end
    end
    
    def set_belo_and_aelo_and_result
      self.result = if self.player1goal > self.player2goal
        1
      elsif self.player1goal == self.player2goal
        0
      else
        -1
      end
      self.player1belo = player1.elo
      self.player2belo = player2.elo
      p1 = Elo::Player.new rating: self.player1belo
      p2 = Elo::Player.new rating: self.player2belo
      if result == -1
          p1.loses_from p2
      elsif result == 0
          p1.plays_draw p2
      else
          p1.wins_from p2
      end
      self.player1aelo = p1.rating
      self.player2aelo = self.player2belo - self.player1aelo + self.player1belo
      self.save
      player1.update_attributes elo: self.player1aelo
      player2.update_attributes elo: self.player2aelo
    end
    
    def result_in_text
      player1goal.to_s + " - " + player2goal.to_s
    end
end

class PlayersController < ApplicationController
  before_action :set_player, only: [:show, :edit, :update, :destroy]
  http_basic_authenticate_with name: "yoroshiku", password: "yoroshiku", except: [:index, :show]
  
  # GET /players
  # GET /players.json
  def index
    @players = Player.order(elo: :desc).to_a
    @group1 = @players.first(3)
    @group2 = @players.first(6) - @group1 = @players.first(3)
    @group3 = @players.last(4)
    @all_elo = Event.all.inject([]){|s,e| s|=eval(e.elos).values}
    @min = @all_elo.min - 20
    @max = @all_elo.max + 20
  end

  # GET /players/1
  # GET /players/1.json
  def show
    @games = @player.games.sort_by(&:id).reverse
    @games_data = []
    @games.each_with_index do |g, i|
      @games_data << if g.player1id == @player.id
        [i+1, g.player1aelo]
      else
        [i+1, g.player2aelo]
      end
    end
    @events_data = []
    Event.all.sort_by(&:id).each do |e|
      @events_data << [e.name, eval(e.elos)[@player.id]]
    end
    @min = @games_data.map(&:last).min - 20
    @max = @games_data.map(&:last).max + 20
  end

  # GET /players/new
  def new
    @player = Player.new
  end

  # GET /players/1/edit
  def edit
  end

  # POST /players
  # POST /players.json
  def create
    @player = Player.new(player_params)

    respond_to do |format|
      if @player.save
        format.html { redirect_to @player, notice: 'Player was successfully created.' }
        format.json { render :show, status: :created, location: @player }
      else
        format.html { render :new }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /players/1
  # PATCH/PUT /players/1.json
  def update
    respond_to do |format|
      if @player.update(player_params)
        format.html { redirect_to @player, notice: 'Player was successfully updated.' }
        format.json { render :show, status: :ok, location: @player }
      else
        format.html { render :edit }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1
  # DELETE /players/1.json
  def destroy
    @player.destroy
    respond_to do |format|
      format.html { redirect_to players_url, notice: 'Player was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_params
      params.require(:player).permit(:name, :image_url, :elo)
    end
end

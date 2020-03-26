require "gosu"
require "net/http"
require "json"

class Cursor
    attr_reader :x, :y, :now_touching
    def initialize(window)
        @window = window
        @x = @window.mouse_x
        @y = @window.mouse_y
        @now_touching = -1       # 触ってる台座[0: left, 1: center, 2: right, -1: non]
        @image = Gosu::Image.new('media/CursorHand.png')
    end

    def update
        if touch?(100,100, 200,300)
            @now_touching = 0
        elsif touch?(250,100, 350,300)
            @now_touching = 1
        elsif touch?(400,100, 500,300)
            @now_touching = 2
        else
            @now_touching = -1
        end
        @x = @window.mouse_x
        @y = @window.mouse_y
    end

    def draw
        @image.draw(@x, @y, 0)
    end

    def touch?(x1, y1, x2, y2)
        @x >= x1 && @x <= x2 && @y >= y1 && @y <= y2 ? true : false
    end
end

class Table
    NeedleWidth = 10
    NeedleHeight= 140
    TableWidth  = 100
    TableHeight = 10

    def initialize(x, y)
        @x = x
        @y = y
    end

    def draw
        # draw Needle
        Gosu::draw_rect(@x+45, @y+50, NeedleWidth, NeedleHeight, Gosu::Color::WHITE)
        # draw Table
        Gosu::draw_rect(@x, @y+190, TableWidth, TableHeight, Gosu::Color::WHITE)
    end
end

class Ring
    attr_accessor :ring0, :ring1, :ring2, :ringPositions, :topRings
    RingHeight = 20
    RingWidth  = 100
    WidthDiff  = 5
    def initialize(window)
        @window = window
        @ring0 = @ring1 = @ring2 = @ring3 = @ring4 = @ring5 = false
        @ringPositions = [0, 0, 0, 0, 0, 0]    # xl, l, m, s, xs
        @topRings = [5, -1, -1]
    end

    def update
        @topRings = [-1, -1, -1]
        @ringPositions.map.with_index do |ring, i|
            @topRings[ring] = i
        end
    end

    # Ring drawing
    def draw(font)
        drawRing0(font)   # XXL
        drawRing1(font)   # XL
        drawRing2(font)   # L
        drawRing3(font)   # M
        drawRing4(font)   # S
        drawRing5(font)   # XS
    end

    def drawRing5(font)
        if @ring5
            x = @window.mouse_x - (RingWidth - WidthDiff*10)/2
            y = @window.mouse_y - RingHeight/2
        else
            x = 100 + @ringPositions[5] * 150 + WidthDiff*5
            y = 270
            y -= RingHeight if @ringPositions[5] == @ringPositions[0]
            y -= RingHeight if @ringPositions[5] == @ringPositions[1]
            y -= RingHeight if @ringPositions[5] == @ringPositions[2]
            y -= RingHeight if @ringPositions[5] == @ringPositions[3]
            y -= RingHeight if @ringPositions[5] == @ringPositions[4]
        end
        Gosu::draw_rect(x, y, RingWidth - WidthDiff*10, RingHeight, Gosu::Color::GRAY)
        font.draw_text("1", x+20, y+3, 1, 1.0, 1.0, Gosu::Color::BLACK)
    end
    def drawRing4(font)
        if @ring4
            x = @window.mouse_x - (RingWidth - WidthDiff*8)/2
            y = @window.mouse_y - RingHeight/2
        else
            x = 100 + @ringPositions[4] * 150 + WidthDiff*4
            y = 270
            y -= RingHeight if @ringPositions[4] == @ringPositions[0]
            y -= RingHeight if @ringPositions[4] == @ringPositions[1]
            y -= RingHeight if @ringPositions[4] == @ringPositions[2]
            y -= RingHeight if @ringPositions[4] == @ringPositions[3]
        end
        Gosu::draw_rect(x, y, RingWidth - WidthDiff*8, RingHeight, Gosu::Color::YELLOW)
        font.draw_text("2", x+25, y+3, 1, 1.0, 1.0, Gosu::Color::BLACK)
    end

    def drawRing3(font)
        if @ring3
            x = @window.mouse_x - (RingWidth - WidthDiff*6)/2
            y = @window.mouse_y - RingHeight/2
        else
            x = 100 + @ringPositions[3] * 150 + WidthDiff*3
            y = 270
            y -= RingHeight if @ringPositions[3] == @ringPositions[0]
            y -= RingHeight if @ringPositions[3] == @ringPositions[1]
            y -= RingHeight if @ringPositions[3] == @ringPositions[2]
        end
        Gosu::draw_rect(x, y, RingWidth - WidthDiff*6, RingHeight, Gosu::Color::AQUA)
        font.draw_text("3", x+30, y+3, 1, 1.0, 1.0, Gosu::Color::BLACK)
    end

    def drawRing2(font)
        if @ring2
            x = @window.mouse_x - (RingWidth - WidthDiff*4)/2
            y = @window.mouse_y - RingHeight/2
        else
            x = 100 + @ringPositions[2] * 150 + WidthDiff*2
            y = @ringPositions[2] == @ringPositions[0] ? (@ringPositions[2] == @ringPositions[1] ? 270 - RingHeight*2 : 270 - RingHeight) : (@ringPositions[2] == @ringPositions[1] ? 270 - RingHeight : 270)
        end
        Gosu::draw_rect(x, y, RingWidth - WidthDiff*4, RingHeight, Gosu::Color::GREEN)
        font.draw_text("4", x+35, y+3, 1, 1.0, 1.0, Gosu::Color::BLACK)
    end
    def drawRing1(font)
        if @ring1
            x = @window.mouse_x - (RingWidth - WidthDiff*2)/2
            y = @window.mouse_y - RingHeight/2
        else
            x = 100 + @ringPositions[1] * 150 + WidthDiff
            y = @ringPositions[1] == @ringPositions[0] ? 270 - RingHeight : 270
        end
        Gosu::draw_rect(x , y, RingWidth - WidthDiff*2, RingHeight, Gosu::Color::FUCHSIA)
        font.draw_text("5", x+40, y+3, 1, 1.0, 1.0, Gosu::Color::BLACK)
    end
    def drawRing0(font)
        if @ring0
            x = @window.mouse_x - RingWidth/2
            y = @window.mouse_y - RingHeight/2
        else
            x = 100 + @ringPositions[0] * 150
            y = 270
        end
        Gosu::draw_rect(x, y, RingWidth, RingHeight, Gosu::Color::RED)
        font.draw_text("6", x+45, y+3, 1, 1.0, 1.0, Gosu::Color::BLACK)
    end

    # RING TOUCHING
    def touchRing0
        touchNone
        @ring0 = true
    end
    def touchRing1
        touchNone
        @ring1 = true
    end
    def touchRing2
        touchNone
        @ring2 = true
    end
    def touchRing3
        touchNone
        @ring3 = true
    end
    def touchRing4
        touchNone
        @ring4 = true
    end
    def touchRing5
        touchNone
        @ring5 = true
    end
    def touchNone
        @ring0 = @ring1 = @ring2 = @ring3 = @ring4 = @ring5 = false
    end

end

class Scoreboard
    def initialize
        data = File.read("api.txt")
        @uri = URI.parse(data)
        @http = Net::HTTP.new(@uri.host, @uri.port)
        @http.use_ssl = @uri.scheme === "https"
    end

    def get
        response = @http.get(@uri.path)
        return JSON.parse(response.body)["data"]
    end

    def post(count, time, name)
        params = {count: count, time: time, scored_by: name}
        headers = { "Content-Type" => "application/json" }
        response = @http.post(@uri.path, params.to_json, headers)
        return JSON.parse(response.body)["status"]
    end
end

class Hanoi < Gosu::Window
    def initialize
        super 600, 400
        self.caption = 'Tower of Hanoi'

        @scene = :start

        @bg = Gosu::Image.new("media/bg.png")
        @logo = Gosu::Image.new("media/logo.png")
        @start_light = Gosu::Image.new("media/start_light_half.png")
        @start_btn = Gosu::Image.new("media/start.png")

        @was_light  = Gosu::Image.new("media/moto.png")
        @will_light = Gosu::Image.new("media/mokuteki2.png")

        # score
        @count = 0
        @start_time = @game_time = Time.now
        @clear_time = @clear_count = -1

        # init CurSor
        @cursor = Cursor.new(self)
        @is_hold_ring = false
        @was_placed = -1
        @now_have   = -1

        # init Tables
        @tables = Array.new
        3.times {|t| @tables << Table.new(100+150*t, 100)}

        # init Rings
        @rings = Ring.new(self)

        # font
        @font15 = Gosu::Font.new(15)
        @font25 = Gosu::Font.new(25)

        # show and post online scoreboard
        @scoreboard = Scoreboard.new
        @rankboard = @scoreboard.get

        # set username
        file = File.read("username.txt")
        file_string = file.to_s
        @username = file_string.split("=").delete_at(1)
    end
    
    def init_game
        @rings.ringPositions = [0, 0, 0, 0, 0, 0]
        @count = 0
        @start_time = @game_time = Time.now
        @clear_time = @clear_count = -1
    end
    
    def update
        # update Cursor (x,y)
        @cursor.update

        case @scene
        when :start
            if @cursor.touch?(140, 305, 450, 365) && (button_down? Gosu::MsLeft)
                init_game
                @scene = :game
            end
            if @cursor.touch?(430, 12, 580, 30) && (button_down? Gosu::MsLeft)
                @rankboard = @scoreboard.get
                @scene = :ranking
            end
            # 140 ,250,   450, 310
        when :game
                # リングをつかむ時
            if (button_down? Gosu::MsLeft) && @rings.topRings[@cursor.now_touching] > -1 && !@is_hold_ring && @cursor.now_touching != -1
                @rings.send("touchRing#{@rings.topRings[@cursor.now_touching]}")    # @rings.touchRing0...
                @is_hold_ring = true
                @was_placed = @cursor.now_touching
                @now_have = @rings.topRings[@cursor.now_touching]
            elsif @is_hold_ring && !(button_down? Gosu::MsLeft) # リングを放すとき
                if @cursor.now_touching > -1    # カーソルがどれかの針を示している
                    unless @now_have < @rings.topRings[@cursor.now_touching]    # 持っているリングより小さい奴の上に乗せられない
                        @count += 1 unless @rings.ringPositions[@rings.topRings[@was_placed]] == @cursor.now_touching
                        @rings.ringPositions[@rings.topRings[@was_placed]] = @cursor.now_touching
                    end
                end
                @rings.touchNone
                @is_hold_ring = false
                @was_placed = -1
                @now_have = -1
            end

            @rings.update

            @game_time = (Time.now - @start_time).to_i

            # when clear
            if @rings.ringPositions == [1,1,1,1,1,1] || @rings.ringPositions == [2,2,2,2,2,2]
                @clear_time = @game_time if @clear_time == -1   # first clear time
                @clear_count = @count if @clear_count == -1
            end

            # to reset
            if @cursor.touch?(3,5,36,14) && (button_down? Gosu::MsLeft)
                @scene = :start
            end

            # to ranking
            if @cursor.touch?(250, 370, 355, 395) && (button_down? Gosu::MsLeft)
                @scoreboard.post(@clear_count, @clear_time, @username)
                @rankboard = @scoreboard.get
                @scene = :ranking
            end
        when :ranking
            # reset
            if @cursor.touch?(3,5,36,14) && (button_down? Gosu::MsLeft)
                @scene = :start
            end
        end
        

        # if push ESCAPE , close the window
        close if Gosu.button_down? Gosu::KbEscape
    end

    def draw
        @bg.draw(0,0,0)
        
        case @scene
        when :start
            if @cursor.touch?(430, 12, 580, 30)
                Gosu::draw_rect(430, 12, 148, 20, Gosu::Color.rgba(119, 136, 153, 255))
            else
                Gosu::draw_rect(430, 12, 148, 20, Gosu::Color.rgba(119, 136, 153, 100))
            end
            @font25.draw_text("RANK BOARD", 430, 10, 1, 1.0, 1.0, Gosu::Color::BLACK)
            @start_light.draw(-40, -15, 0) if @cursor.touch?(140, 305, 450, 365)
            @logo.draw(25, 130, 0)
            @start_btn.draw(150, 315, 0)
        when :game
            if @is_hold_ring && @cursor.now_touching > -1 && @cursor.now_touching != @was_placed
                @will_light.draw(100+150*@cursor.now_touching, 100, 0)
            end
    
            # @table.draw
            @tables.map{|table| table.draw }
    
            # Rings draw
            @rings.draw(@font15)
    
            # cleared
            if @clear_time != -1
                @font15.draw_text("CLEAR TIME:#{@clear_time}", 255, 320, 1, 1.0, 1.0, Gosu::Color::WHITE)
                @font15.draw_text("COUNT:#{@clear_count}", 270, 350, 1, 1.0, 1.0, Gosu::Color::WHITE)
                @font15.draw_text("show RANKING", 253, 380, 1, 1.0, 1.0, Gosu::Color::WHITE)
            end
            @font15.draw_text("Time: #{@game_time}", 450, 30, 1, 1.0, 1.0, Gosu::Color::WHITE)
            @font15.draw_text("count:#{@count}", 450, 60, 1, 1.0, 1.0, Gosu::Color::WHITE)
            if @cursor.touch?(3,5,36,14)
                Gosu::draw_rect(3, 5, 34, 10, Gosu::Color.rgba(119, 136, 153, 255))
            else
                Gosu::draw_rect(3, 5, 34, 10, Gosu::Color.rgba(119, 136, 153, 100))
            end
            @font15.draw_text("reset", 5, 2, 1, 1.0, 1.0, Gosu::Color::WHITE)
        when :ranking
            10.times do |t|
                Gosu::draw_rect(95, 61 + t*25, 400, 24, Gosu::Color.rgba(180, 180, 180, 80))
                t == 0 ? ranking = "1st" : t == 1 ? ranking = "2nd" : t == 2 ? ranking = "3rd" : ranking = (t+1).to_s + "th"
                @font25.draw_text(ranking, 100, 60 + t*25, 1, 1.0, 1.0, Gosu::Color::BLACK)
                if @rankboard[t]
                    @font25.draw_text("#{@rankboard[t]["scored_by"]}", 150, 60 + t*25, 1, 1.0, 1.0, Gosu::Color::BLACK)
                    @font25.draw_text("count:#{@rankboard[t]["count"]}, time:#{@rankboard[t]["time"]}sec", 265, 60 + t*25, 1, 1.0, 1.0, Gosu::Color::BLACK)
                end
            end
            if @cursor.touch?(3,5,36,14)
                Gosu::draw_rect(3, 5, 34, 10, Gosu::Color.rgba(119, 136, 153, 255))
            else
                Gosu::draw_rect(3, 5, 34, 10, Gosu::Color.rgba(119, 136, 153, 100))
            end
            @font15.draw_text("reset", 5, 2, 1, 1.0, 1.0, Gosu::Color::WHITE)
            @font25.draw_text("Your record .. count:#{@count}, Time: #{@clear_time}", 120, 350, 1, 1.0, 1.0, Gosu::Color::WHITE) unless @clear_count == -1
        end
        # @font15.draw_text("x:#{self.mouse_x}\ny:#{self.mouse_y}", 50, 50, 1, 1.0, 1.0, Gosu::Color::WHITE)
        # draw MouseCursor
        @cursor.draw

    end
end

Hanoi.new.show
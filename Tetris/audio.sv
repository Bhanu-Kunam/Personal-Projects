module tetris_audio (
    input  logic        clk,
    input  logic        reset,
    input  logic        start_game,
    input  logic        game_over,
    input  logic        tetromino_locked, 
    input  logic        line_cleared,     
    output logic        audio_out
);

    localparam [31:0] note1 = 32'd151745;
    localparam [31:0] note2 = 32'd202479;
    localparam [31:0] note3 = 32'd191113;
    localparam [31:0] note4 = 32'd170262;

    localparam [31:0] thud = 32'd454545;
    localparam [31:0] ding = 32'd113636;
    
    localparam [31:0] tempo = 32'd25000000;
    localparam [31:0] sfx_time = 32'd10000000;

    logic [31:0] music_timer;
    logic [31:0] sfx_timer;
    logic [1:0]  note_index;
    logic sfx_bool; // 1 =(Ding), 0 =(Thud)
    logic [31:0] current_period;
    
    // Edge Detection
    logic prev_locked, prev_clear;
    logic locked_edge, clear_edge;

    always_ff @(posedge clk) 
    begin
        if (reset) 
        begin
            music_timer <= 32'd0;
            note_index <= 2'd0;
            sfx_timer <= 32'd0;
            sfx_bool <= 1'b0;
            prev_locked <= 1'b0;
            prev_clear  <= 1'b0;
        end
        else
        begin
            prev_locked <= tetromino_locked;
            prev_clear  <= line_cleared;
            locked_edge <= (tetromino_locked && !prev_locked);
            clear_edge  <= (line_cleared && !prev_clear);

            if (music_timer >= tempo)
            begin
                music_timer <= 32'd0;
                note_index  <= note_index + 1'b1;
            end
            else
            begin
                music_timer <= music_timer + 1'b1;
            end
            
            if (clear_edge)
            begin
                sfx_timer <= sfx_time;
                sfx_bool  <= 1'b1;
            end
            else if (locked_edge)
            begin
                if (sfx_timer == 0 || sfx_bool == 1'b0)
                begin
                    sfx_timer <= sfx_time;
                    sfx_bool  <= 1'b0;
                end
            end
            else if (sfx_timer > 0)
            begin
                sfx_timer <= sfx_timer - 1'b1;
            end
        end
    end

    always_comb
    begin
        if (sfx_timer > 0)
        begin
            if (sfx_bool)
            begin
                current_period = ding;
            end
            else
            begin
                current_period = thud;
            end
        end
        else
        begin
            case (note_index)
                2'd0:
                begin
                    current_period = note1;
                end
                2'd1:
                begin
                    current_period = note2;
                end
                2'd2:
                begin
                    current_period = note3;
                end
                2'd3:
                begin
                    current_period = note4;
                end
                default:
                begin
                    current_period = note1;
                end
            endcase
        end
    end

    audio_pwm pwm_gen (
        .clk(clk),
        .rst(reset),
        .en(!start_game && !game_over), 
        .period(current_period),
        .width(current_period >> 1), 
        .pwm(audio_out)
    );

endmodule
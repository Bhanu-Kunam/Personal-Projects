module tetris_control (
    input  logic        Clk,
    input  logic        Reset,
    input  logic [7:0]  keycode,
    input  logic        spawn_possible,
    input  logic        tetromino_locked,
    input  logic        line_scan_done,
    
    output logic [2:0]  state_out
);
    // states
    localparam [2:0] state_start = 3'd0;
    localparam [2:0] state_play = 3'd1;
    localparam [2:0] state_check_lines = 3'd2;
    localparam [2:0] state_spawn = 3'd3;
    localparam [2:0] state_game_over = 3'd4;

    logic [2:0] state, next_state;
    assign state_out = state;

    always_ff @(posedge Clk) begin
        if (Reset)
            state <= state_start;
        else
            state <= next_state;
    end

    always_comb
    begin
        next_state = state;
        case (state)
            state_start:
            begin
                // press space bar
                if (keycode == 8'h2C)
                    next_state = state_spawn;
            end
            state_spawn:
            begin
                if(spawn_possible)
                    next_state = state_play;
                else
                    next_state = state_game_over;
            end
            state_play:
            begin
                if(tetromino_locked)
                    next_state = state_check_lines;
            end
            state_check_lines:
            begin
                if (line_scan_done) 
                    next_state = state_spawn;
            end
            state_game_over:
            begin
                // Enter to play again
                if (keycode == 8'h28)
                    next_state = state_start;
            end
            default:
                next_state = state_start;
        endcase
    end

endmodule
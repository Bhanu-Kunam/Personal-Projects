module tetris_game_controller (
    input  logic        Reset, 
    input  logic        frame_clk,
    input  logic [7:0]  keycode,
    input  logic [9:0]  DrawX,
    input  logic [9:0]  DrawY,

    output logic [9:0]  tetrominoX [4],
    output logic [9:0]  tetrominoY [4],
    output logic [2:0]  tetromino_shape_code,        
    output logic        locked_block_on,    
    output logic [2:0]  locked_block_code,
    output logic        game_over,
    output logic [11:0] score,
    output logic        start_game,
    output logic        tetromino_locked_signal
);

    // states
    localparam [2:0] state_start = 3'd0;
    localparam [2:0] state_play = 3'd1;
    localparam [2:0] state_check_lines = 3'd2;
    localparam [2:0] state_spawn = 3'd3;
    localparam [2:0] state_game_over = 3'd4;

    logic [2:0] state, state_fsm;

    localparam gameboard_x_min = 10'd240;
    localparam gameboard_y_min = 10'd16;
    localparam block_size = 10'd16;
    localparam board_width = 10;
    localparam board_height = 28;

    logic [2:0] board [10][28];
    logic [4:0] grid_x, grid_y;
    logic [1:0] rotation;
    logic [2:0] current_shape_code, next_shape_code;
    
    logic [5:0] gravity_counter, input_delay_counter, current_gravity_limit;
    logic spawn_possible, tetromino_locked, line_scan_done;

    // Gravity
    localparam [5:0] gravity_speed = 6'd30;
    localparam [5:0] faster_gravity_speed = 6'd2;
    localparam [5:0] input_delay = 6'd10;
    
    assign tetromino_shape_code = current_shape_code;
    assign start_game = (state == state_start);
    assign game_over = (state == state_game_over);
    
    assign state = state_fsm;

    // Determine gravity speed
    always_comb 
    begin
        if (keycode == 8'h16)
        begin
            current_gravity_limit = faster_gravity_speed;
        end
        else
        begin
            current_gravity_limit = gravity_speed;
        end
    end

    // fsm
    tetris_control fsm_instiantiate (
        .Clk(frame_clk),
        .Reset(Reset),
        .keycode(keycode),
        .spawn_possible(spawn_possible),
        .tetromino_locked(tetromino_locked),
        .line_scan_done(line_scan_done),
        .state_out(state_fsm)
    );

    logic signed [4:0] draw_rx[4], draw_ry[4], next_rx[4], next_ry[4], grav_rx[4], grav_ry[4], spawn_rx[4], spawn_ry[4];
    
    //sound
    assign tetromino_locked_signal = tetromino_locked;
    
    // offset
    always_comb 
    begin
        logic signed [4:0] bx[4];
        logic signed [4:0] by[4];
        integer i;

        case (current_shape_code)
             3'd1:
             begin
                 bx[0] = -1;
                 by[0] = 0;
                 bx[1] = 0;
                 by[1] = 0;
                 bx[2] = 1;
                 by[2] = 0;
                 bx[3] = 2;
                 by[3] = 0;
             end
             3'd2:
             begin
                 bx[0] = -1;
                 by[0] = -1;
                 bx[1] = -1;
                 by[1] = 0;
                 bx[2] = 0;
                 by[2] = 0;
                 bx[3] = 1;
                 by[3] = 0;
             end
             3'd3:
             begin
                 bx[0] = -1;
                 by[0] = 0;
                 bx[1] = 0;
                 by[1] = 0;
                 bx[2] = 1;
                 by[2] = 0;
                 bx[3] = 1;
                 by[3] = -1;
             end 
             3'd4:
             begin 
                 bx[0] = 0;
                 by[0] = 0;
                 bx[1] = 1;
                 by[1] = 0;
                 bx[2] = 0;
                 by[2] = 1;
                 bx[3] = 1;
                 by[3] = 1;
             end
             3'd5:
             begin 
                 bx[0] = -1;
                 by[0] = 1;
                 bx[1] = 0;
                 by[1] = 1;
                 bx[2] = 0;
                 by[2] = 0;
                 bx[3] = 1;
                 by[3] = 0;
             end
             3'd6:
             begin
                 bx[0] = -1;
                 by[0] = 0;
                 bx[1] = 0;
                 by[1] = 0;
                 bx[2] = 1;
                 by[2] = 0;
                 bx[3] = 0;
                 by[3] = 1;
             end
             3'd7:
             begin 
                 bx[0] = -1;
                 by[0] = 0;
                 bx[1] = 0;
                 by[1] = 0;
                 bx[2] = 0;
                 by[2] = 1;
                 bx[3] = 1;
                 by[3] = 1;
             end
             default:
             begin
                 bx[0] = 0;
                 by[0] = 0;
                 bx[1] = 0;
                 by[1] = 0;
                 bx[2] = 0;
                 by[2] = 0;
                 bx[3] = 0;
                 by[3] = 0;
             end
        endcase

        for (i = 0; i < 4;i = i + 1)
        begin
            if (current_shape_code  == 3'd4)
            begin
                draw_rx[i] = bx[i];
                draw_ry[i] = by[i];
            end
            
            else
            begin
                case (rotation)
                    2'd0:
                    begin
                        draw_rx[i] = bx[i];
                        draw_ry[i] = by[i];
                    end
                    2'd1:
                    begin
                        draw_rx[i] = -by[i];
                        draw_ry[i] = bx[i];
                    end
                    2'd2:
                    begin
                        draw_rx[i] = -bx[i];
                        draw_ry[i] = -by[i];
                    end
                    2'd3:
                    begin
                        draw_rx[i] = by[i];
                        draw_ry[i] = -bx[i];
                    end
                endcase
            end
        end
    end

    // input
    logic [4:0] exp_x;
    logic [1:0] exp_rot;
    logic can_move_input, can_fall;

    always_comb
    begin
        integer i;
        integer cx, cy;
        logic signed [4:0] bx[4];
        logic signed [4:0] by[4];
        logic [1:0] grav_rot;
        logic [4:0] current_x_base;

        exp_x = grid_x;
        exp_rot = rotation;

        if (input_delay_counter == 0)
        begin
            if (keycode == 8'h04)
                exp_x = grid_x - 1;  
            else if (keycode == 8'h07)
                exp_x = grid_x + 1;
            else if (keycode == 8'h1A)
                exp_rot = rotation + 1;
        end
        
        case (current_shape_code)
             3'd1:
             begin
                 bx[0] = -1; by[0] = 0;
                 bx[1] = 0; by[1] = 0;
                 bx[2] = 1; by[2] = 0;
                 bx[3] = 2; by[3] = 0;
             end
             3'd2:
             begin
                 bx[0] = -1; by[0] = -1;
                 bx[1] = -1; by[1] = 0;
                 bx[2] = 0; by[2] = 0;
                 bx[3] = 1; by[3] = 0;
             end
             3'd3:
             begin
                 bx[0] = -1; by[0] = 0;
                 bx[1] = 0;  by[1] = 0;
                 bx[2] = 1;  by[2] = 0;
                 bx[3] = 1;  by[3] = -1;
             end
             3'd4:
             begin
                 bx[0] = 0;  by[0] = 0;
                 bx[1] = 1;  by[1] = 0;
                 bx[2] = 0;  by[2] = 1;
                 bx[3] = 1;  by[3] = 1;
             end
             3'd5:
             begin
                 bx[0] = -1; by[0] = 1;
                 bx[1] = 0;  by[1] = 1;
                 bx[2] = 0;  by[2] = 0;
                 bx[3] = 1;  by[3] = 0;
             end
             3'd6:
             begin
                 bx[0] = -1; by[0] = 0;
                 bx[1] = 0;  by[1] = 0;
                 bx[2] = 1;  by[2] = 0;
                 bx[3] = 0;  by[3] = 1;
             end
             3'd7:
             begin
                 bx[0] = -1; by[0] = 0;
                 bx[1] = 0;  by[1] = 0;
                 bx[2] = 0;  by[2] = 1;
                 bx[3] = 1;  by[3] = 1;
             end
             default:
             begin 
                 bx[0] = 0; by[0] = 0;
                 bx[1] = 0; by[1] = 0;
                 bx[2] = 0; by[2] = 0;
                 bx[3] = 0; by[3] = 0;
             end
        endcase

        for (i = 0; i < 4; i = i + 1)
        begin
            if (current_shape_code == 3'd4)
            begin
                next_rx[i] = bx[i];
                next_ry[i] = by[i];
            end
            else
            begin
                case (exp_rot)
                    2'd0:
                    begin
                        next_rx[i] = bx[i];
                        next_ry[i] = by[i];
                    end
                    2'd1:
                    begin 
                        next_rx[i] = -by[i];
                        next_ry[i] = bx[i];
                    end
                    2'd2:
                    begin
                        next_rx[i] = -bx[i];
                        next_ry[i] = -by[i];
                    end
                    2'd3:
                    begin
                        next_rx[i] = by[i];
                        next_ry[i] = -bx[i];
                    end
                endcase
            end
        end

        // Input Collision
        can_move_input = 1'b1;
        for (i = 0; i < 4; i = i + 1)
        begin
            cx = {27'd0, exp_x} + {{27{next_rx[i][4]}}, next_rx[i]};
            cy = {27'd0, grid_y} + {{27{next_ry[i][4]}}, next_ry[i]};
            
            if (cx < 0 || cx >= board_width || cy >= board_height || (cy >= 0 && board[cx][cy] != 0))
            begin
                can_move_input = 1'b0;
            end
        end
        
        if (can_move_input)
        begin
            grav_rot = exp_rot;
        end
        else
        begin
            grav_rot = rotation;
        end
        
        for (i = 0; i < 4; i = i + 1)
        begin
            if (current_shape_code == 3'd4)
            begin
                grav_rx[i] = bx[i];
                grav_ry[i] = by[i];
            end
            else
            begin
                case (grav_rot)
                    2'd0:
                    begin
                        grav_rx[i] = bx[i];
                        grav_ry[i] = by[i];
                    end
                    2'd1:
                    begin
                        grav_rx[i] = -by[i];
                        grav_ry[i] = bx[i];
                    end
                    2'd2:
                    begin
                        grav_rx[i] = -bx[i];
                        grav_ry[i] = -by[i];
                    end
                    2'd3:
                    begin
                        grav_rx[i] = by[i];
                        grav_ry[i] = -bx[i];
                    end
                endcase
            end
        end

        // Gravity Collision
        can_fall = 1'b1;
        for (i = 0; i < 4; i = i + 1) 
        begin
            if (can_move_input)
            begin
                current_x_base = exp_x;
            end
            else
            begin
                current_x_base = grid_x;
            end

            cx = {27'd0, current_x_base} + {{27{grav_rx[i][4]}}, grav_rx[i]};
            cy = {27'd0, grid_y} + 1 + {{27{grav_ry[i][4]}}, grav_ry[i]};
            
            if (cx < 0 || cx >= board_width || cy >= board_height || (cy >= 0 && board[cx][cy] != 0))
            begin
                can_fall = 1'b0;
            end
        end
    end
    
    // Spawnm
    always_comb 
    begin
        logic signed [4:0] bx[4];
        logic signed [4:0] by[4];
        integer i, sx, sy;

        // offsets
        case (next_shape_code)
             3'd1:
             begin
                 bx[0] = -1; by[0] = 0;
                 bx[1] = 0; by[1] = 0;
                 bx[2] = 1; by[2] = 0;
                 bx[3] = 2; by[3] = 0;
             end
             3'd2:
             begin
                 bx[0] = -1; by[0] = -1;
                 bx[1] = -1; by[1] = 0;
                 bx[2] = 0; by[2] = 0;
                 bx[3] = 1; by[3] = 0;
             end
             3'd3:
             begin
                 bx[0] = -1; by[0] = 0;
                 bx[1] = 0; by[1] = 0;
                 bx[2] = 1; by[2] = 0;
                 bx[3] = 1; by[3] = -1;
             end
             3'd4:
             begin
                 bx[0] = 0; by[0] = 0;
                 bx[1] = 1; by[1] = 0;
                 bx[2] = 0; by[2] = 1;
                 bx[3] = 1; by[3] = 1;
             end
             3'd5:
             begin
                 bx[0] = -1; by[0] = 1;
                 bx[1] = 0; by[1] = 1;
                 bx[2] = 0; by[2] = 0;
                 bx[3] = 1; by[3] = 0;
             end
             3'd6:
             begin
                 bx[0] = -1; by[0] = 0;
                 bx[1] = 0; by[1] = 0;
                 bx[2] = 1; by[2] = 0;
                 bx[3] = 0; by[3] = 1;
             end
             3'd7:
             begin
                 bx[0] = -1; by[0] = 0;
                 bx[1] = 0;  by[1] = 0;
                 bx[2] = 0;  by[2] = 1;
                 bx[3] = 1;  by[3] = 1;
             end
             default:
             begin
                 bx[0] = 0; by[0] = 0;
                 bx[1] = 0; by[1] = 0;
                 bx[2] = 0; by[2] = 0;
                 bx[3] = 0; by[3] = 0;
             end
        endcase
        
        for ( i = 0; i < 4; i = i + 1)
        begin
            if (next_shape_code == 3'd4)
            begin
                spawn_rx[i] = bx[i];
                spawn_ry[i] = by[i];
            end
            else
            begin
                spawn_rx[i] = bx[i];
                spawn_ry[i] = by[i];
            end
        end

        spawn_possible = 1'b1;
        for (i = 0; i < 4; i = i + 1)
        begin
            sx = 5 + {{27{spawn_rx[i][4]}}, spawn_rx[i]};
            sy = 0 + {{27{spawn_ry[i][4]}}, spawn_ry[i]};
            
            if (sx < 0 || sx >= board_width || sy >= board_height)
            begin
                spawn_possible = 1'b0;
            end
            else if (sy >= 0 && board[sx][sy] != 3'd0)
            begin
                spawn_possible = 1'b0;
            end
        end
    end

    // state logic
    always_ff @(posedge frame_clk) 
    begin
        integer k, x, y, i;
        integer lx, ly;
        logic row_full;
        logic line_cleared;

        if (Reset)
        begin
            grid_x <= 5'd5;
            grid_y <= 5'd0;
            rotation <= 2'd0;
            current_shape_code <= 3'd1;
            next_shape_code <= 3'd2;
            gravity_counter <= 0;
            input_delay_counter <= 0;
            score <= 12'd0;
            tetromino_locked <= 1'b0;
            line_scan_done <= 1'b0;
            
            for ( x = 0; x < board_width; x = x + 1)
            begin
                for (y = 0; y < board_height; y = y + 1)
                begin
                    board[x][y] <= 3'd0;
                end
            end
        end
        else
        begin
            tetromino_locked <= 1'b0;
            line_scan_done <= 1'b0;

            case (state)
                state_start:
                begin
                    if (keycode == 8'h2C)
                    begin
                        for (x = 0; x < board_width; x = x + 1)
                        begin
                            for (y = 0; y < board_height; y = y + 1)
                            begin
                                board[x][y] <= 3'd0;
                            end
                        end
                        score <= 12'd0;
                    end
                end

                state_play: 
                begin
                    // input handle
                    if (input_delay_counter == 0 && (keycode == 8'h04 || keycode == 8'h07 || keycode == 8'h1A))
                    begin
                        if (can_move_input)
                        begin
                            grid_x <= exp_x;
                            rotation <= exp_rot;
                        end
                        input_delay_counter <= 1;
                    end
                    
                    if (input_delay_counter > 0 && input_delay_counter < input_delay)
                        input_delay_counter <= input_delay_counter + 1;
                    else if (input_delay_counter >= input_delay)
                        input_delay_counter <= 0;

                    // gravity check
                    if (gravity_counter >= current_gravity_limit)
                    begin
                        if (can_fall)
                        begin
                            grid_y <= grid_y + 1;
                            gravity_counter <= 0;
                        end
                        else
                        begin
                            //floor
                            for (i = 0; i < 4; i = i + 1)
                            begin
                                lx = {27'd0, grid_x} + {{27{draw_rx[i][4]}}, draw_rx[i]};
                                ly = {27'd0, grid_y} + {{27{draw_ry[i][4]}}, draw_ry[i]};
                                
                                if (lx >= 0 && lx < board_width && ly >= 0 && ly < board_height) 
                                begin
                                    board[lx][ly] <= current_shape_code;
                                end
                            end
                            tetromino_locked <= 1'b1;
                            gravity_counter <= 0;
                        end
                    end
                    else
                    begin
                        gravity_counter <= gravity_counter + 1;
                    end
                end

                state_check_lines:
                begin
                    line_cleared = 1'b0;
                    
                    for (y = board_height - 1; y >= 0; y = y - 1)
                    begin
                        row_full = 1'b1;
                        
                        for (x = 0; x < board_width; x = x + 1)
                        begin
                            if (board[x][y] == 3'd0)
                            begin
                                row_full = 1'b0;
                            end
                        end

                        if (row_full)
                        begin
                            // Shift rows down
                            for (k = y; k > 0; k = k - 1)
                            begin
                                for (x = 0; x < board_width; x = x + 1)
                                begin
                                    board[x][k] <= board[x][k-1];
                                end
                            end
                            //clear top row
                            for (x = 0; x < board_width; x = x + 1)
                            begin
                                board[x][0] <= 3'd0;
                            end
                            
                            // update score
                            if (score[7:4] == 4'd9)
                            begin
                                score[7:4] <= 4'd0;
                                if (score[11:8] != 4'd9)
                                    score[11:8] <= score[11:8] + 4'd1;
                            end
                            else
                            begin
                                score[7:4] <= score[7:4] + 4'd1;
                            end
                            
                            line_cleared = 1'b1;
                            break;
                        end
                    end
                    
                    if (line_cleared == 1'b0)
                        line_scan_done <= 1'b1;
                end

                state_spawn:
                begin
                    if (spawn_possible)
                    begin
                        grid_x <= 5'd5;
                        grid_y <= 5'd0;
                        rotation <= 2'd0;
                        current_shape_code <= next_shape_code;
                        next_shape_code <= (next_shape_code == 3'd7) ? 3'd1 : next_shape_code + 1;
                        gravity_counter <= 0;
                    end
                end
                
                state_game_over:
                begin
                    //nothing
                end
            endcase
        end
    end

    //output
    always_comb
    begin
        logic signed [4:0] bx[4];
        logic signed [4:0] by[4];
        logic signed [4:0] local_rx[4];
        logic signed [4:0] local_ry[4];
        integer i, tx, ty;
        
        case (current_shape_code)
             3'd1:
             begin 
                 bx[0] = -1; by[0] = 0;
                 bx[1] = 0;  by[1] = 0;
                 bx[2] = 1;  by[2] = 0;
                 bx[3] = 2;  by[3] = 0;
             end
             3'd2:
             begin
                 bx[0] = -1; by[0] = -1;
                 bx[1] = -1; by[1] = 0;
                 bx[2] = 0;  by[2] = 0;
                 bx[3] = 1;  by[3] = 0;
             end
             3'd3:
             begin
                 bx[0] = -1; by[0] = 0;
                 bx[1] = 0;  by[1] = 0;
                 bx[2] = 1;  by[2] = 0;
                 bx[3] = 1;  by[3] = -1;
             end
             3'd4:
             begin
                 bx[0] = 0;  by[0] = 0;
                 bx[1] = 1;  by[1] = 0;
                 bx[2] = 0;  by[2] = 1;
                 bx[3] = 1;  by[3] = 1;
             end
             3'd5:
             begin
                 bx[0] = -1; by[0] = 1;
                 bx[1] = 0;  by[1] = 1;
                 bx[2] = 0;  by[2] = 0;
                 bx[3] = 1;  by[3] = 0;
             end
             3'd6:
             begin
                 bx[0] = -1; by[0] = 0;
                 bx[1] = 0;  by[1] = 0;
                 bx[2] = 1;  by[2] = 0;
                 bx[3] = 0;  by[3] = 1;
             end
             3'd7:
             begin
                 bx[0] = -1; by[0] = 0;
                 bx[1] = 0;  by[1] = 0;
                 bx[2] = 0;  by[2] = 1;
                 bx[3] = 1;  by[3] = 1;
             end
             default:
             begin
                 bx[0] = 0; by[0] = 0;
                 bx[1] = 0; by[1] = 0;
                 bx[2] = 0; by[2] = 0;
                 bx[3] = 0; by[3] = 0;
             end
        endcase

        for (i = 0; i < 4; i = i + 1)
        begin
            if (current_shape_code == 3'd4)
            begin
                local_rx[i] = bx[i];
                local_ry[i] = by[i];
            end
            else
            begin
                case (rotation)
                    2'd0:
                    begin
                        local_rx[i] = bx[i];
                        local_ry[i] = by[i];
                    end
                    2'd1:
                    begin
                        local_rx[i] = -by[i];
                        local_ry[i] = bx[i];
                    end
                    2'd2:
                    begin
                        local_rx[i] = -bx[i];
                        local_ry[i] = -by[i];
                    end
                    2'd3:
                    begin
                        local_rx[i] = by[i];
                        local_ry[i] = -bx[i];
                    end
                endcase
            end
        end

        for (i = 0; i < 4; i = i + 1)
        begin
            tx = {27'd0, grid_x} + {{27{local_rx[i][4]}}, local_rx[i]};
            ty = {27'd0, grid_y} + {{27{local_ry[i][4]}}, local_ry[i]};
            
            tetrominoX[i] = gameboard_x_min + (tx * block_size);
            tetrominoY[i] = gameboard_y_min + (ty * block_size);
        end
    end

    always_comb
    begin
        integer rx, ry;
        locked_block_on = 1'b0;
        locked_block_code = 3'd0;
        
        if (DrawX >= gameboard_x_min && DrawX < (gameboard_x_min + board_width* block_size) && DrawY >= gameboard_y_min && DrawY < (gameboard_y_min+ board_height *block_size)) 
        begin
            rx = (DrawX - gameboard_x_min) >> 4;
            ry = (DrawY - gameboard_y_min) >> 4;
            if (board[rx][ry] != 0)
            begin
                locked_block_on = 1'b1;
                locked_block_code = board[rx][ry];
            end
        end
    end
endmodule
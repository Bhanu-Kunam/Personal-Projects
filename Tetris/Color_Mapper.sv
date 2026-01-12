module color_mapper (
    input  logic [9:0] tetrominoX [4],
    input  logic [9:0] tetrominoY [4],
    input  logic [9:0] DrawX,
    input  logic [9:0] DrawY,
    input  logic locked_block,
    input  logic [2:0] locked_block_color_code,
    input  logic [2:0] tetromino_color_code,
    input  logic game_over,
    input  logic [11:0] score,
    input  logic start_game,
    input  logic [7:0] char_data,
    
    output logic [6:0] char_addr,
    output logic [2:0] char_row,
    output logic [3:0] Red, Green, Blue
);
    
    logic [9:0] gameboard_x_min, gameboard_x_max, gameboard_y_min, gameboard_y_max, scoreboard_x_min, scoreboard_x_max, scoreboard_y_min, scoreboard_y_max;
    logic in_game_area, on_border, in_score_area, tetromino_on, center_logo_on, side_logo_on, score_txt_on, score_points_on, game_over_on, start_txt_on;
    logic [2:0] font_bit_index;
    logic [2:0] palette_select;
    logic [3:0] palette_r, palette_g, palette_b;

    assign gameboard_x_min = 10'd240;
    assign gameboard_x_max = 10'd400;
    assign gameboard_y_min = 10'd16;
    assign gameboard_y_max = 10'd464;
    assign scoreboard_x_min = 10'd430;
    assign scoreboard_x_max = 10'd550;
    assign scoreboard_y_min = 10'd50;
    assign scoreboard_y_max = 10'd150;
    
    assign in_game_area = (DrawX >= gameboard_x_min) & (DrawX < gameboard_x_max) & (DrawY >= gameboard_y_min) & (DrawY < gameboard_y_max);
    
    assign on_border = (
        (DrawX >= gameboard_x_min - 4 && DrawX < gameboard_x_min && DrawY >= gameboard_y_min - 4 && DrawY < gameboard_y_max + 4) |
        (DrawX >= gameboard_x_max && DrawX < gameboard_x_max + 4 && DrawY >= gameboard_y_min - 4 && DrawY < gameboard_y_max + 4) |
        (DrawY >= gameboard_y_min - 4 && DrawY < gameboard_y_min && DrawX >= gameboard_x_min - 4 && DrawX < gameboard_x_max + 4) |
        (DrawY >= gameboard_y_max && DrawY < gameboard_y_max + 4 && DrawX >= gameboard_x_min - 4 && DrawX < gameboard_x_max + 4)
    );
    
    assign in_score_area = (DrawX >= scoreboard_x_min) & (DrawX < scoreboard_x_max) & (DrawY >= scoreboard_y_min) & (DrawY < scoreboard_y_max);
    
    // palette
    always_comb
    begin
        if (tetromino_on)
        begin
            palette_select = tetromino_color_code;
        end
        else if (locked_block)
        begin
            palette_select = locked_block_color_code;
        end
        else
        begin
            palette_select = 3'd0;
        end
    end
    
    // look up for palette
    always_comb
    begin
        case (palette_select)
            3'd1:
            begin
                palette_r = 4'h0;
                palette_g = 4'hf;
                palette_b = 4'hf;
            end
            3'd2:
            begin
                palette_r = 4'h0;
                palette_g = 4'h0;
                palette_b = 4'hf;
            end
            3'd3:
            begin
                palette_r = 4'hf;
                palette_g = 4'h8;
                palette_b = 4'h0;
            end
            3'd4:
            begin
                palette_r = 4'hf;
                palette_g = 4'hf;
                palette_b = 4'h0;
            end
            3'd5:
            begin
                palette_r = 4'h0;
                palette_g = 4'hf;
                palette_b = 4'h0;
            end
            3'd6:
            begin
                palette_r = 4'h8;
                palette_g = 4'h0;
                palette_b = 4'h8;
            end
            3'd7:
            begin
                palette_r = 4'hf;
                palette_g = 4'h0;
                palette_b = 4'h0;
            end
            default:
            begin
                palette_r = 4'hf;
                palette_g = 4'hf;
                palette_b = 4'hf;
            end
        endcase
    end

    always_comb
    begin
        char_addr = 7'd0;
        char_row = 3'd0;
        center_logo_on = 1'b0;
        side_logo_on = 1'b0;
        score_txt_on = 1'b0;
        score_points_on = 1'b0;
        game_over_on = 1'b0;
        start_txt_on = 1'b0;
        font_bit_index = 3'd0;
        
        // start screen
        // x = 224; y = 120
        if  (start_game && DrawY >= 120 && DrawY < 152 && DrawX >= 224 && DrawX < 416)
        begin
            char_row = (DrawY - 120) >> 2;
            case ((DrawX - 224) >> 5)
                0: char_addr = 7'h54;
                1: char_addr = 7'h45;
                2: char_addr = 7'h54;
                3: char_addr = 7'h52;
                4: char_addr = 7'h49;
                5: char_addr = 7'h53;
                default:
                    char_addr = 7'h00;
            endcase
            font_bit_index = 7 - ((DrawX - 224) >> 2 & 3'b111);
            if(char_addr != 0 && char_data[font_bit_index])
            begin
                center_logo_on = 1'b1;
            end
        end

        // during game
        // x = 24; y = 120;
        else if (!start_game && DrawY >= 120 && DrawY < 152 && DrawX >= 24 && DrawX < 216)
        begin
            char_row = (DrawY - 120) >> 2;
            case ((DrawX - 24) >> 5)
                0: char_addr = 7'h54;
                1: char_addr = 7'h45;
                2: char_addr = 7'h54;
                3: char_addr = 7'h52;
                4: char_addr = 7'h49;
                5: char_addr = 7'h53;
                default:
                    char_addr = 7'h00;
            endcase
            font_bit_index = 7 - ((DrawX - 24) >> 2 & 3'b111);
            if (char_addr != 0 && char_data[font_bit_index])
            begin
                side_logo_on = 1'b1;
            end
        end
        
        // start screen text
        // x = 104; y = 240
        else if (start_game && DrawY >= 240 && DrawY < 256 && DrawX >= 104 && DrawX < 536)
        begin
            char_row = (DrawY - 240) >> 1;
            case ((DrawX - 104) >> 4)
                0: char_addr = 7'h50;
                1: char_addr = 7'h52;
                2: char_addr = 7'h45;
                3: char_addr = 7'h53;
                4: char_addr = 7'h53;
                5: char_addr = 7'h00;
                6: char_addr = 7'h54;
                7: char_addr = 7'h48;
                8: char_addr = 7'h45;
                9: char_addr = 7'h00;
                10: char_addr = 7'h53;
                11: char_addr = 7'h50;
                12: char_addr = 7'h41;
                13: char_addr = 7'h43;
                14: char_addr = 7'h45;
                15: char_addr = 7'h00;
                16: char_addr = 7'h42;
                17: char_addr = 7'h41;
                18: char_addr = 7'h52;
                19: char_addr = 7'h00;
                20: char_addr = 7'h54;
                21: char_addr = 7'h4F;
                22: char_addr = 7'h00;
                23: char_addr = 7'h50;
                24: char_addr = 7'h4C;
                25: char_addr = 7'h41;
                26: char_addr = 7'h59;
                default:
                    char_addr = 7'h00;
            endcase
            font_bit_index = 7 - ((DrawX - 104) >> 1 & 3'b111);
            if (char_addr != 0 && char_data[font_bit_index])
            begin
                start_txt_on = 1'b1;
            end
        end

        // score text
        // x = 450; y = 70
        else if(!start_game && in_score_area && DrawY >= 70 && DrawY < 86 && DrawX >= 450 && DrawX < 530)
        begin
            char_row = (DrawY - 70) >> 1;
            case ((DrawX - 450) >> 4)
                0: char_addr = 7'h53;
                1: char_addr = 7'h43;
                2: char_addr = 7'h4F;
                3: char_addr = 7'h52;
                4: char_addr = 7'h45;
                default:
                    char_addr = 7'h00;
            endcase
            font_bit_index = 7 - ((DrawX - 450) >> 1 & 3'b111);
            if  (char_addr != 0 && char_data[font_bit_index])
            begin
                score_txt_on = 1'b1;
            end
        end
        
        // score points
        // x = 466; y = 100
        else if (!start_game && in_score_area && DrawY >= 100 && DrawY < 116 && DrawX >= 466 && DrawX < 514)
        begin
            char_row = (DrawY - 100) >> 1;
            case ((DrawX - 466) >> 4)
                0: char_addr = {3'b011, score[11:8]};
                1: char_addr = {3'b011, score[7:4]};
                2: char_addr = {3'b011, score[3:0]};
                default:
                    char_addr = 7'h00;
            endcase
            font_bit_index = 7 - ((DrawX - 466) >> 1 & 3'b111);
            if (char_addr != 0 && char_data[font_bit_index])
            begin
                score_points_on = 1'b1;
            end
        end
        
        // game over text
        // base x = 260; y = 220
        else if (game_over && DrawY >= 220 && DrawY < 236 && DrawX >= 260 && DrawX < 404)
        begin
            char_row = (DrawY - 220) >> 1;
            case ((DrawX - 260) >> 4)
                0: char_addr = 7'h47;
                1: char_addr = 7'h41;
                2: char_addr = 7'h4D;
                3: char_addr = 7'h45;
                4: char_addr = 7'h00;
                5: char_addr = 7'h4F;
                6: char_addr = 7'h56;
                7: char_addr = 7'h45;
                8: char_addr = 7'h52;
                default:
                    char_addr = 7'h00;
            endcase
            font_bit_index = 7 - ((DrawX - 260) >> 1 & 3'b111);
            if (char_addr != 0 && char_data[font_bit_index])
            begin
                game_over_on = 1'b1;
            end
        end
    end

    // tetromino falling check
    always_comb
    begin
        tetromino_on = 1'b0;
        if   (!start_game)
        begin
            for  (int i = 0; i < 4; i++)
            begin
                if(DrawX >= tetrominoX[i] && DrawX < (tetrominoX[i] + 16) && DrawY >= tetrominoY[i] && DrawY < (tetrominoY[i] + 16) && DrawY >= gameboard_y_min)
                begin
                    tetromino_on = 1'b1;
                end
            end
        end
    end
        
    // output
    always_comb
    begin
        logic [3:0] base_r, base_g, base_b;

        if (start_game)
        begin
             // black background for start
             if (center_logo_on)
             begin
                 if ((DrawX - 224) < 32)
                 begin
                     base_r = 4'hf;
                     base_g = 4'h0;
                     base_b = 4'h0;
                 end
                 else if ((DrawX - 224) < 64)
                 begin
                     base_r = 4'hf;
                     base_g = 4'h8;
                     base_b = 4'h0;
                 end
                 else if ((DrawX - 224) < 96)
                 begin
                     base_r = 4'hf;
                     base_g = 4'hf;
                     base_b = 4'h0;
                 end
                 else if ((DrawX - 224) < 128)
                 begin
                     base_r = 4'h0;
                     base_g = 4'hf;
                     base_b = 4'h0;
                 end
                 else if ((DrawX - 224) < 160)
                 begin
                     base_r = 4'h0;
                     base_g = 4'h0;
                     base_b = 4'hf;
                 end
                 else
                 begin
                     base_r = 4'h8;
                     base_g = 4'h0;
                     base_b = 4'h8;
                 end       
             end
             else if (start_txt_on)
             begin
                 base_r = 4'hf;
                 base_g = 4'hf;
                 base_b = 4'hf;
             end
             else
             begin
                 base_r = 4'h0;
                 base_g = 4'h0;
                 base_b = 4'h0;
             end
        end
        else
        begin
            if  (game_over_on)
            begin
                base_r = 4'hf;
                base_g = 4'hf;
                base_b = 4'hf;
            end
            else if (tetromino_on || locked_block)
            begin
                base_r = palette_r;
                base_g = palette_g;
                base_b = palette_b;
            end
            else if (score_txt_on || score_points_on)
            begin
                base_r = 4'hf;
                base_g = 4'hf;
                base_b = 4'hf;
            end
            else if (side_logo_on)
            begin
                 if ((DrawX - 24) < 32)
                 begin
                     base_r = 4'hf;
                     base_g = 4'h0;
                     base_b = 4'h0;
                 end
                 else if ((DrawX - 24) < 64)
                 begin
                     base_r = 4'hf;
                     base_g = 4'h8;
                     base_b = 4'h0;
                 end
                 else if ((DrawX - 24) < 96)
                 begin
                     base_r = 4'hf;
                     base_g = 4'hf;
                     base_b = 4'h0;
                 end
                 else if ((DrawX - 24) < 128)
                 begin
                     base_r = 4'h0;
                     base_g = 4'hf;
                     base_b = 4'h0;
                 end
                 else if ((DrawX - 24) < 160)
                 begin
                     base_r = 4'h0;
                     base_g = 4'h0;
                     base_b = 4'hf;
                 end
                 else
                 begin
                     base_r = 4'h8;
                     base_g = 4'h0;
                     base_b = 4'h8;
                 end
            end
            else if (on_border)
            begin
                base_r = 4'hf;
                base_g = 4'hf;
                base_b = 4'hf;
            end
            else if (in_game_area)
            begin
                base_r = 4'h0;
                base_g = 4'h0;
                base_b = 4'h0;
            end
            else if (in_score_area)
            begin
                base_r = 4'h4;
                base_g = 4'h4;
                base_b = 4'h4;
            end
            else
            begin
                base_r = 4'h0;
                base_g = 4'h0;
                base_b = 4'h8;
            end
        end

        // game over
        if (game_over)
        begin
            if (game_over_on)
            begin
                Red = 4'hf;
                Green = 4'hf;
                Blue = 4'hf;
            end
            else if (on_border)
            begin
                Red = 4'hf;
                Green = 4'h0;
                Blue = 4'h0;
            end
            else if (tetromino_on || locked_block)
            begin
                Red = 4'h7;
                Green = 4'h7;
                Blue = 4'h7;
            end
            else
            begin
                Red = base_r >> 1;
                Green = base_g >> 1;
                Blue = base_b >> 1;
            end
        end 
        else
        begin
            Red = base_r;
            Green = base_g;
            Blue = base_b;
        end
    end 
    
endmodule
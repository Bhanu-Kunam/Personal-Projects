//-------------------------------------------------------------------------
//    mb_usb_hdmi_top.sv                                                 --
//    Zuofu Cheng                                                        --
//    2-29-24                                                            --
//    10-14-25                                                           --
//                                                                       --
//    Fall 2025 Distribution                                           --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module mb_usb_hdmi_top(
    input logic Clk,
    input logic reset_rtl_0,
    
    //USB signals
    input logic [0:0] gpio_usb_int_tri_i,
    output logic gpio_usb_rst_tri_o,
    input logic usb_spi_miso,
    output logic usb_spi_mosi,
    output logic usb_spi_sclk,
    output logic usb_spi_ss,
    
    //UART
    input logic uart_rtl_0_rxd,
    output logic uart_rtl_0_txd,
    
    //HDMI
    output logic hdmi_tmds_clk_n,
    output logic hdmi_tmds_clk_p,
    output logic [2:0]hdmi_tmds_data_n,
    output logic [2:0]hdmi_tmds_data_p,
        
    //HEX displays
    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB,
    output logic audio_l,
    output logic audio_r
);
    
    logic [31:0] keycode0_gpio, keycode1_gpio;
    logic clk_25MHz, clk_125MHz, clk, clk_100MHz;
    logic locked;
    logic [9:0] drawX, drawY, ballxsig, ballysig, ballsizesig;

    logic hsync, vsync, vde;
    logic [3:0] red, green, blue;
    logic reset_ah;
    
    assign reset_ah = reset_rtl_0;
    
    
    //Keycode HEX drivers
    hex_driver HexA (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[31:28], keycode0_gpio[27:24], keycode0_gpio[23:20], keycode0_gpio[19:16]}),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );
    
    hex_driver HexB (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[15:12], keycode0_gpio[11:8], keycode0_gpio[7:4], keycode0_gpio[3:0]}),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    );
    
    mb_block mb_block_i (
        .clk_100MHz(Clk),
        .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
        .gpio_usb_keycode_0_tri_o(keycode0_gpio),
        .gpio_usb_keycode_1_tri_o(keycode1_gpio),
        .gpio_usb_rst_tri_o(gpio_usb_rst_tri_o),
        .reset_rtl_0(~reset_ah), //Block designs expect active low reset, all other modules are active high
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .usb_spi_miso(usb_spi_miso),
        .usb_spi_mosi(usb_spi_mosi),
        .usb_spi_sclk(usb_spi_sclk),
        .usb_spi_ss(usb_spi_ss)
    );
        
    //clock wizard configured with a 1x and 5x clock for HDMI
    clk_wiz_0 clk_wiz (
        .clk_out1(clk_25MHz),
        .clk_out2(clk_125MHz),
        .reset(reset_ah),
        .locked(locked),
        .clk_in1(Clk)
    );
    
    //VGA Sync signal generator
    vga_controller vga (
        .pixel_clk(clk_25MHz),
        .reset(reset_ah),
        .hs(hsync),
        .vs(vsync),
        .active_nblank(vde),
        .drawX(drawX),
        .drawY(drawY)
    );    

    //Real Digital VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(clk_25MHz),
        .pix_clkx5(clk_125MHz),
        .pix_clk_locked(locked),
        .rst(reset_ah),
        //Color and Sync Signals
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync),
        .vde(vde),
        
        //aux Data (unused)
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        
        //Differential outputs
        .TMDS_CLK_P(hdmi_tmds_clk_p),          
        .TMDS_CLK_N(hdmi_tmds_clk_n),          
        .TMDS_DATA_P(hdmi_tmds_data_p),         
        .TMDS_DATA_N(hdmi_tmds_data_n)          
    );

    
//    //Ball Module
//    ball ball_instance(
//        .Reset(reset_ah),
//        .frame_clk(vsync),                    //Figure out what this should be so that the ball will move
//        .keycode(keycode0_gpio[7:0]),    //Notice: only one keycode connected to ball by default
//        .BallX(ballxsig),
//        .BallY(ballysig),
//        .BallS(ballsizesig)
//    );

    //Tetris Controller Module
    
    // Define some wires
    logic [9:0] tetrominoX_signal [4];
    logic [9:0] tetrominoY_signal [4];
    logic [2:0] tetrominoCode_signal;
    
    logic locked_on_signal;
    logic [2:0] locked_code_signal;
    logic game_over_signal;
    logic [11:0] score_signal;
    logic start_game_signal;

    logic [6:0] char_addr;
    logic [2:0] char_row;
    logic [7:0] char_data;
    
    logic block_locked_pulse;
    logic line_cleared_pulse;
    logic pwm_audio_signal;
    logic [11:0] prev_score;
    
    always_ff @(posedge vsync) begin
        if (reset_ah) prev_score <= 12'd0;
        else prev_score <= score_signal;
    end
    
    assign line_cleared_pulse = (score_signal != prev_score);
    
    // Audio
    tetris_audio audio_unit (
        .clk(Clk),
        .reset(reset_ah),
        .tetromino_locked(block_locked_pulse),
        .line_cleared(line_cleared_pulse),
        .audio_out(pwm_audio_signal)
    );
    
    assign audio_l = pwm_audio_signal;
    assign audio_r = pwm_audio_signal;

    // Instantiate char ROM
    char_rom char_rom_initiate (
        .ascii_addr(char_addr),
        .char_row(char_row),
        .data(char_data)
    );

    // Tetris Controller
    tetris_game_controller tetris_instance(
        .Reset(reset_ah),
        .frame_clk(vsync),   
        .keycode(keycode0_gpio[7:0]),    
        .tetrominoX(tetrominoX_signal),
        .tetrominoY(tetrominoY_signal),
        .tetromino_shape_code(tetrominoCode_signal),
        .DrawX(drawX),
        .DrawY(drawY),
        .locked_block_on(locked_on_signal),
        .locked_block_code(locked_code_signal),
        .game_over(game_over_signal),
        .score(score_signal),
        .start_game(start_game_signal),
        .tetromino_locked_signal(block_locked_pulse) 
    );

    // Color Mapper
    color_mapper color_initiate (
        .tetrominoX(tetrominoX_signal),
        .tetrominoY(tetrominoY_signal),
        .DrawX(drawX),
        .DrawY(drawY),
        .locked_block(locked_on_signal),
        .locked_block_color_code(locked_code_signal),
        .tetromino_color_code(tetrominoCode_signal),
        .game_over(game_over_signal),
        .score(score_signal),
        .start_game(start_game_signal),
        .char_data(char_data),
        .char_addr(char_addr),
        .char_row(char_row),
        .Red(red),
        .Green(green),
        .Blue(blue)
    );
    
endmodule

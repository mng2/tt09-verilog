/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    reg [7:0] phase;
    reg [7:0] mixin;
    // All output pins must be assigned. If not used, assign to 0.
    always @(posedge clk) begin
        phase <= ui_in;
        mixin <= uio_in;
    end    
    
    wire signed [7:0] sine1;
    reg  signed [7:0] sine1reg;
    sine_lookup inst_sine(
        .phase  (phase),
        .sample (sine1)
    );

    reg signed [15:0] product;
    reg signed [8:0] final_out;
    always @(posedge clk) begin
        sine1reg <= sine1;
        product <= sine1reg * mixin;
        // output is planned to be R2R DAC
        final_out <= (product >> 8) + 8'sd127;
    end

    assign uo_out = final_out[7:0];
    assign uio_out = 0;
    assign uio_oe  = 0;

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, rst_n, 1'b0};

endmodule

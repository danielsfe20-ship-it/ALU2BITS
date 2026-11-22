`default_nettype none

module tt_um_alu_2bit (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire [2:0] a  = ui_in[2:0];  
    wire [2:0] b  = ui_in[5:3];
    wire [1:0] op = ui_in[7:6];

    // Resultados intermedios
    wire [3:0] suma = {1'b0, a} + {1'b0, b};
    wire [3:0] dif  = {1'b0, a} - {1'b0, b};   // bit 3 = 1 si A < B (préstamo)
    wire [5:0] prod = a * b;                   // producto completo (máximo 7*7=49)

    // Señales de salida internas
    reg [3:0] y;
    reg       c; //c (carry / borrow)
    reg       z; //z (zero flag)
    reg       e; //e (error - división por cero)

    always @(*) begin
        // Valores por defecto (evitan latches)
        y = 4'b0000;
        c = 1'b0;
        e = 1'b0;

        case (op)
            2'b00: begin                    // SUMA
                y = suma;
                // c se queda en 0 (no hay carry de 4 bits en este diseño)
            end

            2'b01: begin                    // RESTA
                y = dif;
                c = dif[3];                 // préstamo si A < B
            end

            2'b10: begin                    // MULTIPLICACIÓN
                y = prod[3:0];              // 4 bits bajos
                c = |prod[5:4];             // hay bits altos → acarreo
            end

            2'b11: begin                    // DIVISIÓN
                if (b == 3'b000) begin
                    e = 1'b1;               // error: división entre cero
                    y = 4'b0000;
                end else begin
                    y = {1'b0, a / b};      // cociente (máximo 7)
                end
            end
        endcase

        // Flag de cero: resultado = 0 y no hay carry ni error
        z = (y == 4'b0000) && !c && !e;
    end

    // Asignación a los pines de salida
    assign uo_out[3:0] = y;      // y0..y3
    assign uo_out[4]   = c;      // carry / borrow
    assign uo_out[5]   = z;      // zero
    assign uo_out[6]   = e;      // error (división por 0)
    assign uo_out[7]   = 1'b0;   // no usado

    // Pines bidireccionales no usados → configurar como entradas
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Evitar warnings de señales no usadas
    wire _unused = &{ena, clk, rst_n, uio_in, 1'b0};

endmodule

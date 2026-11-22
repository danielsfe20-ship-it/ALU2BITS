module tt_um_alu_2bit (
    input  wire [2:0] a,
    input  wire [2:0] b,
    input  wire [1:0] op,
    output reg  [3:0] y,
    output reg        c,
    output reg        z,
    output reg        e
);

    // Resultados intermedios
    wire [3:0] suma = {1'b0, a} + {1'b0, b};
    wire [3:0] dif  = {1'b0, a} - {1'b0, b};   // bit 3 = 1 si A < B
    wire [5:0] prod = a * b;                   // producto completo (maximo 49)

    // "always @(*)" = logica combinacional: se recalcula cada vez
    // que cambia cualquier entrada.
    always @(*) begin
        // Valores por defecto (evitan latches no deseados)
        y = 4'b0000;
        c = 1'b0;
        e = 1'b0;

        case (op)
            2'b00: begin                    // SUMA
                y = suma;
            end
            2'b01: begin                    // RESTA
                y = dif;
                c = dif[3];                 // prestamo si A < B
            end
            2'b10: begin                    // MULTIPLICACION
                y = prod[3:0];              // maximo F
                c = |prod[5:4];             // sobrante = acarreo
            end
            2'b11: begin                    // DIVISION
                if (b == 3'b000) begin
                    e = 1'b1;               // division entre cero
                end else begin
                    y = {1'b0, a / b};      // cociente
                end
            end
        endcase

        // Cero: resultado completo igual a cero, sin acarreo ni error
        z = (y == 4'b0000) && !c && !e;
    end

endmodule
